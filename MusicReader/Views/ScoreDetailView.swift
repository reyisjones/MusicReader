import SwiftUI

struct ScoreDetailView: View {
    let score: MusicScore
    @ObservedObject var midiPlayer: MIDIPlayer
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingExportOptions = false
    @State private var currentPage = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Score Header
                ScoreHeaderView(score: score)
                
                // Playback Controls
                PlaybackControlsView(midiPlayer: midiPlayer, score: score)
                
                // Score Content Area
                ScrollView {
                    VStack(spacing: 20) {
                        // Metadata Section
                        MetadataSection(score: score)
                        
                        // Parts List
                        PartsListSection(score: score)
                        
                        // Future: Score Notation View would go here
                        NotationPlaceholderView()
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Score Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingExportOptions = true }) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { /* TODO: Share functionality */ }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            midiPlayer.loadScore(score)
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(score: score)
        }
    }
}

/// Header view showing score title and composer
struct ScoreHeaderView: View {
    let score: MusicScore
    
    var body: some View {
        VStack(spacing: 8) {
            Text(score.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            if !score.composer.isEmpty {
                Text("by \(score.composer)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            if let arranger = score.arranger, !arranger.isEmpty {
                Text("arranged by \(arranger)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

/// Playback controls section
struct PlaybackControlsView: View {
    @ObservedObject var midiPlayer: MIDIPlayer
    let score: MusicScore
    
    var body: some View {
        VStack(spacing: 16) {
            // Main playback controls
            HStack(spacing: 20) {
                // Previous/Rewind (future feature)
                Button(action: { midiPlayer.seek(to: 0) }) {
                    Image(systemName: "backward.end.fill")
                        .font(.title2)
                }
                .disabled(midiPlayer.playbackState != .stopped)
                
                // Play/Pause button
                Button(action: togglePlayback) {
                    Image(systemName: playButtonIcon)
                        .font(.title)
                        .frame(width: 50, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                
                // Stop button
                Button(action: { midiPlayer.stop() }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .disabled(midiPlayer.playbackState == .stopped)
                
                // Next (future feature)
                Button(action: { /* TODO */ }) {
                    Image(systemName: "forward.end.fill")
                        .font(.title2)
                }
                .disabled(true)
            }
            
            // Progress bar
            VStack(spacing: 8) {
                ProgressView(value: midiPlayer.currentTime, 
                           total: midiPlayer.totalDuration)
                    .progressViewStyle(LinearProgressViewStyle())
                
                HStack {
                    Text(formatTime(midiPlayer.currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(midiPlayer.totalDuration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Additional controls
            HStack {
                // Tempo control
                VStack {
                    Text("Tempo")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("-") {
                            midiPlayer.setTempo(midiPlayer.currentTempo - 10)
                        }
                        .disabled(midiPlayer.currentTempo <= 30)
                        
                        Text("\(Int(midiPlayer.currentTempo))")
                            .font(.caption)
                            .frame(width: 40)
                        
                        Button("+") {
                            midiPlayer.setTempo(midiPlayer.currentTempo + 10)
                        }
                        .disabled(midiPlayer.currentTempo >= 300)
                    }
                }
                
                Spacer()
                
                // Volume control
                VStack {
                    Text("Volume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "speaker.fill")
                            .font(.caption)
                        
                        Slider(value: $midiPlayer.volume, in: 0...1)
                            .frame(width: 80)
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Loop toggle
                Button(action: { midiPlayer.isLooping.toggle() }) {
                    Image(systemName: midiPlayer.isLooping ? "repeat.1" : "repeat")
                        .font(.title3)
                        .foregroundColor(midiPlayer.isLooping ? .blue : .gray)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private var playButtonIcon: String {
        switch midiPlayer.playbackState {
        case .playing:
            return "pause.fill"
        case .paused, .stopped:
            return "play.fill"
        }
    }
    
    private func togglePlayback() {
        switch midiPlayer.playbackState {
        case .stopped, .paused:
            midiPlayer.play()
        case .playing:
            midiPlayer.pause()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

/// Metadata section showing score information
struct MetadataSection: View {
    let score: MusicScore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                MetadataRow(label: "File", value: score.fileName)
                
                if let keySignature = score.keySignature {
                    MetadataRow(label: "Key", value: keySignature)
                }
                
                if let timeSignature = score.timeSignature {
                    MetadataRow(label: "Time Signature", value: timeSignature)
                }
                
                if let tempo = score.tempo {
                    MetadataRow(label: "Tempo", value: "\(tempo) BPM")
                }
                
                if let copyright = score.copyright {
                    MetadataRow(label: "Copyright", value: copyright)
                }
                
                MetadataRow(label: "Last Modified", 
                          value: DateFormatter.localizedString(from: score.lastModified, 
                                                              dateStyle: .medium, 
                                                              timeStyle: .short))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

/// Individual metadata row
struct MetadataRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .lineLimit(2)
            
            Spacer()
        }
    }
}

/// Parts list section showing instruments
struct PartsListSection: View {
    let score: MusicScore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Instruments (\(score.parts.count))")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(score.parts) { part in
                    PartRowView(part: part)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

/// Individual part row
struct PartRowView: View {
    let part: MusicPart
    
    var body: some View {
        HStack {
            Image(systemName: instrumentIcon(for: part.instrument))
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(part.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(part.instrument)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("Ch. \(part.midiChannel + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(part.notes.count) notes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func instrumentIcon(for instrument: String) -> String {
        let lowercased = instrument.lowercased()
        
        if lowercased.contains("piano") || lowercased.contains("keyboard") {
            return "pianokeys"
        } else if lowercased.contains("guitar") {
            return "guitars"
        } else if lowercased.contains("violin") || lowercased.contains("string") {
            return "violin"
        } else if lowercased.contains("trumpet") || lowercased.contains("horn") {
            return "trumpet"
        } else if lowercased.contains("drum") || lowercased.contains("percussion") {
            return "drum"
        } else {
            return "music.note"
        }
    }
}

/// Placeholder for future notation display
struct NotationPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Musical Notation")
                .font(.headline)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.tertiarySystemBackground))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Notation display coming soon")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("This is where the musical score will be displayed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Export options sheet
struct ExportOptionsView: View {
    let score: MusicScore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Export Options") {
                    Button(action: { exportAsMIDI() }) {
                        Label("Export as MIDI", systemImage: "doc.badge.plus")
                    }
                    
                    Button(action: { exportAsMusicXML() }) {
                        Label("Export as MusicXML", systemImage: "doc.text")
                    }
                    
                    Button(action: { exportAsPDF() }) {
                        Label("Export as PDF", systemImage: "doc.richtext")
                    }
                    .disabled(true) // TODO: Implement PDF export
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func exportAsMIDI() {
        // TODO: Implement MIDI export
        print("Export as MIDI: \(score.title)")
        dismiss()
    }
    
    private func exportAsMusicXML() {
        // TODO: Implement MusicXML export
        print("Export as MusicXML: \(score.title)")
        dismiss()
    }
    
    private func exportAsPDF() {
        // TODO: Implement PDF export
        print("Export as PDF: \(score.title)")
        dismiss()
    }
}

#Preview {
    let sampleScore = MusicScore(
        title: "Sample Song",
        composer: "Demo Composer",
        fileName: "sample.mscz",
        parts: [
            MusicPart(
                name: "Piano",
                instrument: "Piano",
                midiChannel: 0,
                midiProgram: 0,
                notes: [
                    MIDINote(pitch: 60, startTime: 0, duration: 1),
                    MIDINote(pitch: 62, startTime: 1, duration: 1),
                    MIDINote(pitch: 64, startTime: 2, duration: 1)
                ]
            )
        ]
    )
    
    ScoreDetailView(score: sampleScore, midiPlayer: MIDIPlayer())
}
