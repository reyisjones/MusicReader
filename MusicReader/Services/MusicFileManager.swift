import Foundation
import UIKit

/// Service for managing music file operations
@MainActor
class MusicFileManager: ObservableObject {
    @Published var loadedScores: [MusicScore] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, 
                                            in: .userDomainMask).first!
        loadSavedScores()
    }
    
    // MARK: - File Loading
    
    /// Load a music file from a URL
    /// - Parameter url: URL of the music file to load
    func loadMusicFile(from url: URL) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let score = try await processMusicFile(at: url)
            loadedScores.append(score)
            saveScore(score)
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading music file: \(error)")
        }
        
        isLoading = false
    }
    
    /// Process a music file and extract score data
    private func processMusicFile(at url: URL) async throws -> MusicScore {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "mscz":
            return try await processMSCZFile(at: url)
        case "musicxml", "xml":
            return try await processMusicXMLFile(at: url)
        case "mid", "midi":
            return try await processMIDIFile(at: url)
        default:
            throw MusicScoreError.invalidFormat
        }
    }
    
    /// Process a MuseScore (.mscz) file
    private func processMSCZFile(at url: URL) async throws -> MusicScore {
        // Extract the ZIP archive
        let tempDir = try ZipArchive.extractArchive(at: url)
        defer {
            ZipArchive.cleanupTemporaryDirectory(at: tempDir)
        }
        
        // Look for the main .mscx file
        let mscxURL = tempDir.appendingPathComponent("score.mscx")
        
        guard fileManager.fileExists(atPath: mscxURL.path) else {
            throw MusicScoreError.parseError("No score.mscx found in archive")
        }
        
        // Parse the MusicXML content
        return try await parseMusicXML(at: mscxURL, originalURL: url)
    }
    
    /// Process a MusicXML file
    private func processMusicXMLFile(at url: URL) async throws -> MusicScore {
        return try await parseMusicXML(at: url, originalURL: url)
    }
    
    /// Process a MIDI file
    private func processMIDIFile(at url: URL) async throws -> MusicScore {
        // For this demo, we'll create a basic score representation
        // In a real app, you would parse the MIDI file properly
        let fileName = url.lastPathComponent
        
        var score = MusicScore(
            title: fileName.replacingOccurrences(of: ".mid", with: "")
                          .replacingOccurrences(of: ".midi", with: ""),
            composer: "Unknown",
            fileName: fileName
        )
        
        // Create a demo part with some notes
        let demoPart = MusicPart(
            name: "Piano",
            instrument: "Piano",
            midiChannel: 0,
            midiProgram: 0,
            notes: createDemoNotes()
        )
        
        score.parts = [demoPart]
        score.fileURL = url
        score.isLoaded = true
        score.duration = 8.0 // Demo duration
        
        return score
    }
    
    /// Parse MusicXML content
    private func parseMusicXML(at url: URL, originalURL: URL) async throws -> MusicScore {
        let xmlData = try Data(contentsOf: url)
        let parser = MusicXMLParser()
        
        return try await withCheckedThrowingContinuation { continuation in
            parser.parse(xmlData) { result in
                switch result {
                case .success(var score):
                    score.fileURL = originalURL
                    score.fileName = originalURL.lastPathComponent
                    score.isLoaded = true
                    continuation.resume(returning: score)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Demo Data Creation
    
    /// Create demo notes for testing
    private func createDemoNotes() -> [MIDINote] {
        let notes: [(pitch: UInt8, start: Double, duration: Double)] = [
            (60, 0.0, 1.0),  // C4
            (62, 1.0, 1.0),  // D4
            (64, 2.0, 1.0),  // E4
            (65, 3.0, 1.0),  // F4
            (67, 4.0, 1.0),  // G4
            (69, 5.0, 1.0),  // A4
            (71, 6.0, 1.0),  // B4
            (72, 7.0, 1.0),  // C5
        ]
        
        return notes.map { note in
            MIDINote(pitch: note.pitch, 
                    velocity: 80, 
                    startTime: note.start, 
                    duration: note.duration)
        }
    }
    
    // MARK: - Score Management
    
    /// Save a score to local storage
    private func saveScore(_ score: MusicScore) {
        let scoresURL = documentsDirectory.appendingPathComponent("scores.json")
        
        do {
            let data = try JSONEncoder().encode(loadedScores)
            try data.write(to: scoresURL)
        } catch {
            print("Failed to save scores: \(error)")
        }
    }
    
    /// Load saved scores from local storage
    private func loadSavedScores() {
        let scoresURL = documentsDirectory.appendingPathComponent("scores.json")
        
        // First, try to load sample files from Documents directory
        loadSampleFiles()
        
        guard fileManager.fileExists(atPath: scoresURL.path) else {
            // Create demo score if no saved scores exist
            createDemoScore()
            return
        }
        
        do {
            let data = try Data(contentsOf: scoresURL)
            let savedScores = try JSONDecoder().decode([MusicScore].self, from: data)
            // Merge with any existing scores from sample files
            for score in savedScores {
                if !loadedScores.contains(where: { $0.fileName == score.fileName }) {
                    loadedScores.append(score)
                }
            }
        } catch {
            print("Failed to load saved scores: \(error)")
            if loadedScores.isEmpty {
                createDemoScore()
            }
        }
    }
    
    /// Load sample files from Documents directory
    private func loadSampleFiles() {
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            
            for fileURL in files {
                let fileName = fileURL.lastPathComponent
                let fileExtension = fileURL.pathExtension.lowercased()
                
                // Skip non-music files
                guard ["musicxml", "xml", "mid", "midi", "mscz"].contains(fileExtension) else {
                    continue
                }
                
                // Skip if already loaded
                if loadedScores.contains(where: { $0.fileName == fileName }) {
                    continue
                }
                
                // Load the file asynchronously
                Task {
                    do {
                        let score = try await processMusicFile(at: fileURL)
                        await MainActor.run {
                            loadedScores.append(score)
                        }
                    } catch {
                        print("Failed to load sample file \(fileName): \(error)")
                    }
                }
            }
        } catch {
            print("Failed to read Documents directory: \(error)")
        }
    }
    
    /// Create a demo score for testing
    private func createDemoScore() {
        let demoPart = MusicPart(
            name: "Piano",
            instrument: "Piano",
            midiChannel: 0,
            midiProgram: 0,
            notes: createDemoNotes()
        )
        
        let demoScore = MusicScore(
            title: "Demo Song - C Major Scale",
            composer: "Music Reader Demo",
            fileName: "demo.mscz",
            parts: [demoPart]
        )
        
        loadedScores.append(demoScore)
    }
    
    /// Delete a score
    func deleteScore(_ score: MusicScore) {
        loadedScores.removeAll { $0.id == score.id }
        saveScore(MusicScore()) // Trigger save
    }
    
    /// Get score by ID
    func getScore(by id: UUID) -> MusicScore? {
        return loadedScores.first { $0.id == id }
    }
}

// MARK: - MusicXML Parser

/// Simple MusicXML parser for extracting basic score information
private class MusicXMLParser: NSObject, XMLParserDelegate {
    private var score: MusicScore?
    private var currentElement: String = ""
    private var currentPart: MusicPart?
    private var currentNote: MIDINote?
    private var currentTime: Double = 0
    private var completion: ((Result<MusicScore, Error>) -> Void)?
    
    func parse(_ data: Data, completion: @escaping (Result<MusicScore, Error>) -> Void) {
        self.completion = completion
        self.score = MusicScore()
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        if parser.parse() {
            if let score = score {
                completion(.success(score))
            } else {
                completion(.failure(MusicScoreError.parseError("Failed to create score")))
            }
        } else {
            completion(.failure(MusicScoreError.parseError("XML parsing failed")))
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        switch elementName {
        case "score-part":
            if let partId = attributeDict["id"] {
                currentPart = MusicPart(name: partId, instrument: "Unknown")
            }
        case "note":
            currentNote = MIDINote(pitch: 60, startTime: currentTime, duration: 1.0)
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        switch currentElement {
        case "work-title":
            score?.title = trimmed
        case "creator":
            score?.composer = trimmed
        case "part-name":
            currentPart?.name = trimmed
        case "instrument-name":
            currentPart?.instrument = trimmed
        case "step":
            if currentNote != nil {
                // Convert step + octave to MIDI pitch
                // This is simplified - real implementation would handle accidentals
                let pitchMap: [String: UInt8] = ["C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11]
                if let basePitch = pitchMap[trimmed] {
                    currentNote?.pitch = basePitch + 60 // Default to octave 4
                }
            }
        case "octave":
            if let note = currentNote, let octave = Int(trimmed) {
                let currentPitch = note.pitch % 12
                currentNote?.pitch = UInt8(octave * 12 + Int(currentPitch))
            }
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "score-part":
            if let part = currentPart {
                score?.parts.append(part)
            }
            currentPart = nil
        case "note":
            if currentNote != nil, var part = currentPart {
                if let note = currentNote {
                    part.notes.append(note)
                    currentPart = part
                    currentTime += note.duration
                }
            }
            currentNote = nil
        default:
            break
        }
        
        currentElement = ""
    }
}
