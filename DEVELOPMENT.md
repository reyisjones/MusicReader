# 🔧 MusicReader Development Guide

This guide provides detailed information for developers who want to understand, modify, or extend the MusicReader iOS app.

## 📋 Table of Contents

1. [Project Structure](#project-structure)
2. [Architecture Overview](#architecture-overview)
3. [Key Components](#key-components)
4. [MIDI Implementation](#midi-implementation)
5. [File Handling](#file-handling)
6. [UI Components](#ui-components)
7. [Adding New Features](#adding-new-features)
8. [Testing](#testing)
9. [Troubleshooting](#troubleshooting)

---

## 📁 Project Structure

```
MusicReader/
├── MusicReader.xcodeproj/        # Xcode project file
├── MusicReader/                  # Main source directory
│   ├── MusicReaderApp.swift      # App entry point (@main)
│   ├── Views/                    # SwiftUI view components
│   │   ├── ContentView.swift     # Main library view
│   │   ├── ScoreDetailView.swift # Score player interface
│   │   └── DocumentPicker.swift  # File import components
│   ├── Models/                   # Data models
│   │   └── MusicScore.swift      # Core data structures
│   ├── Services/                 # Business logic layer
│   │   ├── MusicFileManager.swift # File operations
│   │   └── MIDIPlayer.swift      # Audio playback
│   ├── Utilities/                # Helper classes
│   │   └── ZipArchive.swift      # ZIP file handling
│   ├── Assets.xcassets/          # App icons and images
│   ├── Info.plist               # App configuration
│   └── Preview Content/          # SwiftUI preview assets
├── Readme.md                     # Main documentation
├── DEVELOPMENT.md               # This file
└── build.sh                     # Build automation script
```

---

## 🏗 Architecture Overview

### Design Pattern: MVVM (Model-View-ViewModel)

- **Models**: Data structures (`MusicScore`, `MusicPart`, `MIDINote`)
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: ObservableObject classes (`MusicFileManager`, `MIDIPlayer`)

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data binding
- **CoreMIDI**: Low-level MIDI operations
- **AVFoundation**: Audio engine and synthesis
- **Foundation**: File handling, data processing

---

## 🔑 Key Components

### 1. MusicScore (Model)

```swift
struct MusicScore: Identifiable, Codable {
    let id = UUID()
    var title: String
    var composer: String
    var parts: [MusicPart]
    // ... other properties
}
```

**Purpose**: Central data model representing a musical composition
**Key Features**: 
- Unique identification
- Metadata storage
- Part/instrument organization
- Codable for persistence

### 2. MusicFileManager (Service)

```swift
@MainActor
class MusicFileManager: ObservableObject {
    @Published var loadedScores: [MusicScore] = []
    @Published var isLoading: Bool = false
    // ... other properties
}
```

**Purpose**: Handle file import, parsing, and library management
**Key Features**:
- Asynchronous file loading
- Multiple format support (.mscz, .musicxml, .mid)
- Local storage management
- Error handling

### 3. MIDIPlayer (Service)

```swift
@MainActor
class MIDIPlayer: ObservableObject {
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentTime: TimeInterval = 0
    // ... other properties
}
```

**Purpose**: Audio playback and MIDI synthesis
**Key Features**:
- Real-time audio synthesis
- Playback control (play, pause, stop, seek)
- Tempo and volume adjustment
- Multi-channel MIDI support

---

## 🎹 MIDI Implementation

### Audio Pipeline

```
MIDI Events → AVAudioUnitSampler → AVAudioEngine → Audio Output
```

### Key Classes

1. **AVAudioEngine**: Core audio processing
2. **AVAudioUnitSampler**: Software synthesizer
3. **Timer**: Playback timing coordination

### MIDI Event Processing

```swift
private func processMIDIEvent(_ event: TimedMIDINote) {
    if event.isNoteOn {
        sampler.startNote(event.pitch, withVelocity: event.velocity, onChannel: event.channel)
    } else {
        sampler.stopNote(event.pitch, onChannel: event.channel)
    }
}
```

### Timing System

- **High-resolution timer**: 10ms update interval
- **Event scheduling**: Pre-sorted MIDI events by timestamp
- **Seek support**: Jump to any position in the score

---

## 📁 File Handling

### Supported Formats

1. **.mscz (MuseScore)**
   - ZIP archive containing MusicXML
   - Extraction via `ZipArchive` utility
   - Primary target format

2. **.musicxml/.xml**
   - Direct MusicXML parsing
   - Standard interchange format
   - Full metadata support

3. **.mid/.midi**
   - Binary MIDI format
   - Basic note extraction
   - Limited metadata

### File Import Flow

```
File Selection → Security Scope → Copy to Documents → Parse Content → Create MusicScore → Save to Library
```

### Error Handling

```swift
enum MusicScoreError: Error, LocalizedError {
    case fileNotFound
    case invalidFormat
    case parseError(String)
    case zipExtractionFailed
    case midiError(String)
}
```

---

## 🎨 UI Components

### ContentView (Main Interface)

- **Library Display**: List of imported scores
- **Import Controls**: Document picker and drag/drop
- **Loading States**: Progress indicators
- **Error Handling**: Alert presentation

### ScoreDetailView (Player Interface)

- **Metadata Display**: Score information
- **Playback Controls**: Transport controls
- **Progress Tracking**: Visual timeline
- **Settings**: Tempo, volume, loop controls

### DocumentPicker (File Import)

- **UIKit Integration**: `UIDocumentPickerViewController` wrapper
- **Security Handling**: Scoped resource access
- **iPad Support**: Drag and drop functionality

---

## ➕ Adding New Features

### 1. New File Format Support

```swift
// In MusicFileManager.swift
private func processMusicFile(at url: URL) async throws -> MusicScore {
    let fileExtension = url.pathExtension.lowercased()
    
    switch fileExtension {
    case "mscz":
        return try await processMSCZFile(at: url)
    case "newformat":  // Add your new format here
        return try await processNewFormatFile(at: url)
    // ... existing cases
    }
}
```

### 2. New Playback Features

```swift
// In MIDIPlayer.swift
func addNewPlaybackFeature() {
    // Add new @Published properties for UI binding
    // Implement business logic
    // Update UI controls in ScoreDetailView
}
```

### 3. New UI Components

```swift
// Create new SwiftUI view
struct NewFeatureView: View {
    var body: some View {
        // Implementation
    }
}

// Add to existing views
VStack {
    // ... existing content
    NewFeatureView()
}
```

---

## 🧪 Testing

### Manual Testing

1. **File Import Testing**
   ```bash
   # Test with various file formats
   - Download sample .mscz files from MuseScore
   - Test .musicxml files from online repositories
   - Try .mid files from MIDI libraries
   ```

2. **Playback Testing**
   ```bash
   # Test all playback functions
   - Play/pause/stop controls
   - Seek to different positions
   - Tempo changes during playback
   - Volume adjustment
   - Loop functionality
   ```

3. **UI Testing**
   ```bash
   # Test on different devices
   - iPhone (various sizes)
   - iPad (portrait/landscape)
   - Light/dark mode
   - Accessibility features
   ```

### Unit Testing (Future Enhancement)

```swift
import XCTest
@testable import MusicReader

class MusicReaderTests: XCTestCase {
    func testMIDINoteCreation() {
        let note = MIDINote(pitch: 60, startTime: 0, duration: 1)
        XCTAssertEqual(note.noteName, "C4")
    }
    
    func testScoreCreation() {
        let score = MusicScore(title: "Test", composer: "Test Composer")
        XCTAssertEqual(score.title, "Test")
        XCTAssertTrue(score.parts.isEmpty)
    }
}
```

---

## 🐛 Troubleshooting

### Common Issues

1. **Audio Not Playing**
   ```swift
   // Check audio session configuration
   try AVAudioSession.sharedInstance().setCategory(.playback)
   try AVAudioSession.sharedInstance().setActive(true)
   ```

2. **File Import Fails**
   ```swift
   // Verify file access permissions
   guard url.startAccessingSecurityScopedResource() else {
       print("Failed to access security-scoped resource")
       return
   }
   defer { url.stopAccessingSecurityScopedResource() }
   ```

3. **MIDI Timing Issues**
   ```swift
   // Check timer configuration
   playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
       // Update playback
   }
   ```

### Debug Tips

1. **Enable Detailed Logging**
   ```swift
   print("MIDI Event: \(event.pitch) at \(event.timestamp)")
   ```

2. **Use Xcode Instruments**
   - Profile audio performance
   - Monitor memory usage
   - Check for timing issues

3. **Test on Real Devices**
   - Audio latency differs on simulator
   - File access behaviors vary
   - Performance characteristics differ

---

## 🔄 Performance Optimization

### Memory Management

- Use `@Published` sparingly for UI-bound properties
- Implement proper cleanup in `deinit`
- Cache frequently accessed data

### Audio Performance

- Pre-load sound banks
- Minimize real-time allocations
- Use background queues for file processing

### UI Responsiveness

- Use `@MainActor` for UI updates
- Implement async/await for long operations
- Show progress indicators for user feedback

---

## 📚 Additional Resources

### Apple Documentation

- [SwiftUI Framework](https://developer.apple.com/documentation/swiftui)
- [AVFoundation](https://developer.apple.com/documentation/avfoundation)
- [CoreMIDI](https://developer.apple.com/documentation/coremidi)
- [Document-Based Apps](https://developer.apple.com/documentation/uikit/view_controllers/adding_a_document_browser_to_your_app)

### External Libraries (Optional Enhancements)

- [AudioKit](https://audiokit.io/) - Advanced audio processing
- [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) - Robust ZIP handling
- [SWXMLHash](https://github.com/drmohundro/SWXMLHash) - XML parsing

### Community Resources

- [MuseScore](https://musescore.org/) - Sample files and documentation
- [MusicXML](https://www.musicxml.com/) - Format specifications
- [MIDI Association](https://www.midi.org/) - MIDI standards

---

This development guide provides the foundation for understanding and extending the MusicReader app. The codebase is well-structured and documented to support future enhancements and maintenance.
