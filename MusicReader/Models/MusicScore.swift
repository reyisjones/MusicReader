import Foundation

/// Represents a musical score with metadata and content
struct MusicScore: Identifiable, Codable {
    let id: UUID
    
    // Basic metadata
    var title: String
    var composer: String
    var arranger: String?
    var copyright: String?
    var description: String?
    
    // Musical properties
    var keySignature: String?
    var timeSignature: String?
    var tempo: Int? // BPM
    var parts: [MusicPart]
    
    // File information
    var fileName: String
    private var fileURLString: String?
    var lastModified: Date
    
    // Playback properties
    var duration: TimeInterval? // in seconds
    var isLoaded: Bool = false
    
    // Computed property for fileURL
    var fileURL: URL? {
        get {
            guard let urlString = fileURLString else { return nil }
            return URL(string: urlString)
        }
        set {
            fileURLString = newValue?.absoluteString
        }
    }
    
    init(title: String = "Untitled", 
         composer: String = "Unknown", 
         fileName: String = "", 
         parts: [MusicPart] = []) {
        self.id = UUID()
        self.title = title
        self.composer = composer
        self.fileName = fileName
        self.parts = parts
        self.lastModified = Date()
    }
    
    // Custom CodingKeys to exclude fileURL and include fileURLString
    private enum CodingKeys: String, CodingKey {
        case id, title, composer, arranger, copyright, description
        case keySignature, timeSignature, tempo, parts
        case fileName, fileURLString, lastModified
        case duration, isLoaded
    }
}

/// Represents a musical part/instrument in the score
struct MusicPart: Identifiable, Codable {
    let id: UUID
    
    var name: String
    var instrument: String
    var midiChannel: Int
    var midiProgram: Int // MIDI program/patch number
    var transpose: Int = 0 // Semitones to transpose
    var volume: Float = 1.0 // 0.0 to 1.0
    var pan: Float = 0.0 // -1.0 (left) to 1.0 (right)
    var muted: Bool = false
    var solo: Bool = false
    
    // MIDI note events for this part
    var notes: [MIDINote]
    
    init(name: String, 
         instrument: String, 
         midiChannel: Int = 0, 
         midiProgram: Int = 0,
         notes: [MIDINote] = []) {
        self.id = UUID()
        self.name = name
        self.instrument = instrument
        self.midiChannel = midiChannel
        self.midiProgram = midiProgram
        self.notes = notes
    }
}

/// Represents a MIDI note event
struct MIDINote: Identifiable, Codable {
    let id: UUID
    
    var pitch: UInt8 // MIDI note number (0-127)
    var velocity: UInt8 // Note velocity (0-127)
    var startTime: Double // Start time in beats or seconds
    var duration: Double // Duration in beats or seconds
    var channel: UInt8 = 0
    
    // Optional music theory properties
    var noteName: String? // e.g., "C4", "F#5"
    var accidental: String? // e.g., "sharp", "flat", "natural"
    
    init(pitch: UInt8, 
         velocity: UInt8 = 64, 
         startTime: Double, 
         duration: Double,
         channel: UInt8 = 0) {
        self.id = UUID()
        self.pitch = pitch
        self.velocity = velocity
        self.startTime = startTime
        self.duration = duration
        self.channel = channel
        self.noteName = MIDINote.pitchToNoteName(pitch)
    }
    
    /// Convert MIDI pitch number to note name
    static func pitchToNoteName(_ pitch: UInt8) -> String {
        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let octave = Int(pitch / 12) - 1
        let noteIndex = Int(pitch % 12)
        return "\(noteNames[noteIndex])\(octave)"
    }
    
    /// Convert note name to MIDI pitch number
    static func noteNameToPitch(_ noteName: String) -> UInt8? {
        let noteMap: [String: UInt8] = [
            "C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3,
            "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7, "G#": 8,
            "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11
        ]
        
        guard noteName.count >= 2 else { return nil }
        
        let noteNamePart = String(noteName.dropLast())
        let octaveString = String(noteName.last!)
        
        guard let baseNote = noteMap[noteNamePart],
              let octave = Int(octaveString) else { return nil }
        
        return UInt8((octave + 1) * 12 + Int(baseNote))
    }
}

/// Playback state for the score
enum PlaybackState {
    case stopped
    case playing
    case paused
}

/// Error types for music score operations
enum MusicScoreError: Error, LocalizedError {
    case fileNotFound
    case invalidFormat
    case parseError(String)
    case zipExtractionFailed
    case midiError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Music file not found"
        case .invalidFormat:
            return "Invalid or unsupported file format"
        case .parseError(let message):
            return "Parse error: \(message)"
        case .zipExtractionFailed:
            return "Failed to extract compressed music file"
        case .midiError(let message):
            return "MIDI error: \(message)"
        }
    }
}
