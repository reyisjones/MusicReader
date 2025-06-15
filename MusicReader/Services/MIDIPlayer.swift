import Foundation
import CoreMIDI
import AVFoundation
import Combine

/// MIDI Player for playing back music scores
@MainActor
class MIDIPlayer: ObservableObject {
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    @Published var currentTempo: Double = 120.0 // BPM
    @Published var isLooping: Bool = false
    @Published var volume: Float = 0.8
    
    // MIDI-related properties
    private var midiClient: MIDIClientRef = 0
    private var outputPort: MIDIPortRef = 0
    private var virtualDestination: MIDIEndpointRef = 0
    
    // Audio engine for synthesis
    private var audioEngine: AVAudioEngine
    private var sampler: AVAudioUnitSampler
    
    // Playback timing
    private var playbackTimer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    
    // Current score and playback data
    private var currentScore: MusicScore?
    private var sortedNotes: [TimedMIDINote] = []
    private var noteIndex: Int = 0
    
    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.audioEngine = AVAudioEngine()
        self.sampler = AVAudioUnitSampler()
        
        setupAudioEngine()
        setupMIDI()
    }
    
    deinit {
        // Synchronously stop timer and audio
        playbackTimer?.invalidate()
        playbackTimer = nil
        
        // Stop audio engine synchronously
        audioEngine.stop()
        
        // Clean up MIDI resources
        if midiClient != 0 {
            MIDIClientDispose(midiClient)
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupAudioEngine() {
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        
        // Setup audio engine
        audioEngine.attach(sampler)
        audioEngine.connect(sampler, to: audioEngine.outputNode, format: nil)
        
        // Load default sound font
        loadDefaultSoundFont()
        
        // Start audio engine
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func setupMIDI() {
        // Create MIDI client
        let clientName = "MusicReader" as CFString
        let status = MIDIClientCreate(clientName, nil, nil, &midiClient)
        
        if status != noErr {
            print("Failed to create MIDI client: \(status)")
            return
        }
        
        // Create output port
        let portName = "MusicReader Output" as CFString
        MIDIOutputPortCreate(midiClient, portName, &outputPort)
        
        // Create virtual destination for internal routing
        let destName = "MusicReader Virtual Destination" as CFString
        MIDIDestinationCreate(midiClient, destName, { _, _, _ in }, nil, &virtualDestination)
    }
    
    private func loadDefaultSoundFont() {
        // Load a basic General MIDI sound font
        // In a production app, you might bundle sound fonts or use system sounds
        guard let soundBankURL = Bundle.main.url(forResource: "GeneralUser GS MuseScore v1.442", withExtension: "sf2") else {
            // If no sound font is available, use the default sampler preset
            loadDefaultPreset()
            return
        }
        
        do {
            try sampler.loadSoundBankInstrument(at: soundBankURL, 
                                              program: 0, 
                                              bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB), 
                                              bankLSB: UInt8(kAUSampler_DefaultBankLSB))
        } catch {
            print("Failed to load sound font: \(error)")
            loadDefaultPreset()
        }
    }
    
    private func loadDefaultPreset() {
        // Load default piano preset
        let presetURL = Bundle.main.url(forResource: "Piano", withExtension: "aupreset")
        
        if let url = presetURL {
            do {
                try sampler.loadInstrument(at: url)
            } catch {
                print("Failed to load default preset: \(error)")
            }
        }
    }
    
    // MARK: - Playback Control
    
    func loadScore(_ score: MusicScore) {
        currentScore = score
        prepareForPlayback()
    }
    
    private func prepareForPlayback() {
        guard let score = currentScore else { return }
        
        // Convert score to timed MIDI events
        sortedNotes = createTimedMIDIEvents(from: score)
        
        // Calculate total duration
        totalDuration = sortedNotes.last?.timestamp ?? 0
        
        // Reset playback position
        currentTime = 0
        noteIndex = 0
        
        print("Prepared \(sortedNotes.count) MIDI events for playback")
    }
    
    private func createTimedMIDIEvents(from score: MusicScore) -> [TimedMIDINote] {
        var events: [TimedMIDINote] = []
        let beatsPerSecond = Double(score.tempo ?? 120) / 60.0
        
        for part in score.parts {
            for note in part.notes {
                // Convert beat time to real time
                let timestamp = note.startTime / beatsPerSecond
                let duration = note.duration / beatsPerSecond
                
                // Note on event
                events.append(TimedMIDINote(
                    timestamp: timestamp,
                    isNoteOn: true,
                    channel: UInt8(part.midiChannel),
                    pitch: note.pitch,
                    velocity: note.velocity
                ))
                
                // Note off event
                events.append(TimedMIDINote(
                    timestamp: timestamp + duration,
                    isNoteOn: false,
                    channel: UInt8(part.midiChannel),
                    pitch: note.pitch,
                    velocity: 0
                ))
            }
        }
        
        // Sort events by timestamp
        return events.sorted { $0.timestamp < $1.timestamp }
    }
    
    func play() {
        guard currentScore != nil, !sortedNotes.isEmpty else { return }
        
        switch playbackState {
        case .stopped:
            startPlayback()
        case .paused:
            resumePlayback()
        case .playing:
            return // Already playing
        }
    }
    
    func pause() {
        guard playbackState == .playing else { return }
        
        playbackState = .paused
        pausedTime = currentTime
        stopPlaybackTimer()
    }
    
    func stop() {
        playbackState = .stopped
        currentTime = 0
        pausedTime = 0
        noteIndex = 0
        stopPlaybackTimer()
        stopAllNotes()
    }
    
    private func startPlayback() {
        playbackState = .playing
        startTime = Date()
        noteIndex = 0
        startPlaybackTimer()
    }
    
    private func resumePlayback() {
        playbackState = .playing
        startTime = Date().addingTimeInterval(-pausedTime)
        startPlaybackTimer()
    }
    
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updatePlayback()
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func updatePlayback() {
        guard let startTime = startTime else { return }
        
        currentTime = Date().timeIntervalSince(startTime)
        
        // Check if we've reached the end
        if currentTime >= totalDuration {
            if isLooping {
                stop()
                play()
                return
            } else {
                stop()
                return
            }
        }
        
        // Process MIDI events that should happen now
        while noteIndex < sortedNotes.count && sortedNotes[noteIndex].timestamp <= currentTime {
            let event = sortedNotes[noteIndex]
            processMIDIEvent(event)
            noteIndex += 1
        }
    }
    
    private func processMIDIEvent(_ event: TimedMIDINote) {
        if event.isNoteOn {
            playNote(pitch: event.pitch, velocity: event.velocity, channel: event.channel)
        } else {
            stopNote(pitch: event.pitch, channel: event.channel)
        }
    }
    
    private func playNote(pitch: UInt8, velocity: UInt8, channel: UInt8) {
        sampler.startNote(pitch, withVelocity: velocity, onChannel: channel)
    }
    
    private func stopNote(pitch: UInt8, channel: UInt8) {
        sampler.stopNote(pitch, onChannel: channel)
    }
    
    private func stopAllNotes() {
        // Send all notes off on all channels
        for channel in 0..<16 {
            for pitch in 0..<128 {
                sampler.stopNote(UInt8(pitch), onChannel: UInt8(channel))
            }
        }
    }
    
    // MARK: - Seek and Tempo Control
    
    func seek(to time: TimeInterval) {
        let wasPlaying = playbackState == .playing
        
        if wasPlaying {
            pause()
        }
        
        currentTime = min(max(time, 0), totalDuration)
        pausedTime = currentTime
        
        // Find the correct note index for the new time
        noteIndex = 0
        while noteIndex < sortedNotes.count && sortedNotes[noteIndex].timestamp <= currentTime {
            noteIndex += 1
        }
        
        stopAllNotes()
        
        if wasPlaying {
            resumePlayback()
        }
    }
    
    func setTempo(_ newTempo: Double) {
        currentTempo = max(30, min(300, newTempo)) // Clamp between 30-300 BPM
        
        if playbackState == .playing {
            // Recalculate timing with new tempo
            let wasPlaying = playbackState == .playing
            pause()
            prepareForPlayback()
            if wasPlaying {
                play()
            }
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        stop()
        
        // Dispose MIDI client
        if midiClient != 0 {
            MIDIClientDispose(midiClient)
        }
        
        // Stop audio engine
        audioEngine.stop()
    }
}

// MARK: - Helper Structures

/// Represents a MIDI event with timing information
private struct TimedMIDINote {
    let timestamp: TimeInterval
    let isNoteOn: Bool
    let channel: UInt8
    let pitch: UInt8
    let velocity: UInt8
}
