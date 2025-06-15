import SwiftUI

struct ContentView: View {
    @StateObject private var fileManager = MusicFileManager()
    @StateObject private var midiPlayer = MIDIPlayer()
    
    @State private var showDocumentPicker = false
    @State private var selectedScore: MusicScore?
    @State private var showingScoreDetail = false
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Music Reader")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Open and play MuseScore files")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // File Import Section
                VStack(spacing: 16) {
                    // Drag & Drop Zone (iPad)
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        DropZone { url in
                            Task {
                                await fileManager.loadMusicFile(from: url)
                            }
                        }
                    }
                    
                    // Import Button
                    FileImportButton {
                        showDocumentPicker = true
                    }
                }
                .padding(.horizontal)
                
                // Loading Indicator
                if fileManager.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading music file...")
                            .font(.caption)
                    }
                    .padding()
                }
                
                // Scores List
                if !fileManager.loadedScores.isEmpty {
                    List {
                        Section("Your Music Library") {
                            ForEach(fileManager.loadedScores) { score in
                                ScoreRowView(score: score) {
                                    selectedScore = score
                                    showingScoreDetail = true
                                }
                            }
                            .onDelete(perform: deleteScores)
                        }
                    }
                } else if !fileManager.isLoading {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "music.note")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No music files loaded")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Import a .mscz, .musicxml, or .mid file to get started")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Music Reader")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: 
                Button("Import") {
                    showDocumentPicker = true
                }
            )
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    Task {
                        await fileManager.loadMusicFile(from: url)
                    }
                    showDocumentPicker = false
                } onCancel: {
                    showDocumentPicker = false
                }
            }
            .sheet(isPresented: $showingScoreDetail) {
                if let score = selectedScore {
                    ScoreDetailView(score: score, midiPlayer: midiPlayer)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") {
                    fileManager.errorMessage = nil
                }
            } message: {
                Text(fileManager.errorMessage ?? "Unknown error")
            }
            .onChange(of: fileManager.errorMessage) { errorMessage in
                showingAlert = errorMessage != nil
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force single view on iPhone
    }
    
    private func deleteScores(offsets: IndexSet) {
        for index in offsets {
            let score = fileManager.loadedScores[index]
            fileManager.deleteScore(score)
        }
    }
}

/// Row view for displaying a music score in the list
struct ScoreRowView: View {
    let score: MusicScore
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Score Icon
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                // Score Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(score.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("by \(score.composer)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        if !score.parts.isEmpty {
                            Text("\(score.parts.count) part\(score.parts.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let duration = score.duration {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(formatDuration(duration))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Status Indicator
                VStack {
                    if score.isLoaded {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
