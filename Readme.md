# 🎼 MusicReader – iOS/iPadOS App for Reading and Playing Music Files

**MusicReader** is a Swift-based iOS application designed for iPad and iPhone that reads MuseScore files (`.mscz`), MusicXML files, and MIDI files, then plays them back using MIDI synthesis. Perfect for musicians, composers, and educators looking for a lightweight mobile music viewer and player.

---

## 📱 Platforms

- **iOS 15+** (iPhone)
- **iPadOS 15+** (iPad)
- Built using **Swift** and **SwiftUI** in **Xcode 15+**

---

## 🛠 Core Features

### ✅ Implemented Features
- 📂 **File Import**: Import `.mscz`, `.musicxml`, and `.mid` files from the Files app
- 🎯 **Drag & Drop**: iPad support for dragging files directly into the app
- 📄 **File Parsing**: Extract and parse MusicXML content from compressed MuseScore files
- 🎵 **MIDI Playback**: Real-time audio playback using CoreMIDI and AVAudioEngine
- 🎹 **Playback Controls**: Play, pause, stop, seek, tempo adjustment, and volume control
- 📊 **Score Metadata**: Display title, composer, instruments, and timing information
- 💾 **Local Storage**: Automatically save and manage your music library
- 🔄 **Loop Mode**: Repeat playback for practice sessions

### 🎛 Playback Features
- **Tempo Control**: Adjust playback speed from 30-300 BPM
- **Volume Control**: Individual volume adjustment
- **Progress Tracking**: Visual progress bar with time display
- **Looping**: Toggle continuous playback
- **Multi-instrument Support**: Handle multiple MIDI channels and instruments

---

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+**
- **iOS 15.0+** deployment target
- **macOS 13.0+** for development

### Building the App

1. **Clone or download** this repository
2. **Open** `MusicReader.xcodeproj` in Xcode
3. **Select** your target device (iPhone/iPad or Simulator)
4. **Build and run** (⌘+R)

### Code Structure

```
MusicReader/
├── MusicReaderApp.swift          # App entry point
├── Views/                        # SwiftUI views
│   ├── ContentView.swift         # Main app interface
│   ├── ScoreDetailView.swift     # Score viewer and player
│   └── DocumentPicker.swift      # File import interface
├── Models/                       # Data models
│   └── MusicScore.swift          # Score, part, and note models
├── Services/                     # Business logic
│   ├── MusicFileManager.swift    # File handling and parsing
│   └── MIDIPlayer.swift          # Audio playback engine
├── Utilities/                    # Helper classes
│   └── ZipArchive.swift          # ZIP extraction for .mscz files
└── Assets.xcassets              # App icons and assets
```

---

## 📖 Usage Instructions

### Importing Music Files

1. **Tap "Import Music File"** or use the toolbar import button
2. **Select a file** from the Files app picker:
   - `.mscz` - MuseScore files (recommended)
   - `.musicxml` or `.xml` - MusicXML files
   - `.mid` or `.midi` - MIDI files
3. **iPad users** can also drag and drop files directly onto the app

### Playing Music

1. **Tap any score** in your library to open the detailed view
2. **Use playback controls**:
   - **Play/Pause**: Start or pause playback
   - **Stop**: Stop playback and return to beginning
   - **Progress bar**: Tap to seek to any position
   - **Tempo**: Use +/- buttons to adjust speed
   - **Volume**: Drag slider to adjust audio level
   - **Loop**: Toggle repeat mode

### Managing Your Library

- **Delete scores**: Swipe left on any item in the library
- **View details**: Tap any score to see metadata and instruments
- **Automatic saving**: All imported scores are saved locally

---

## � Technical Implementation

### Architecture

- **SwiftUI** for modern, declarative UI
- **MVVM pattern** with ObservableObject for state management
- **CoreMIDI** and **AVAudioEngine** for audio synthesis
- **Combine** framework for reactive programming
- **Native ZIP handling** for .mscz file extraction

### MIDI Implementation

- **Real-time synthesis** using AVAudioUnitSampler
- **Multi-channel support** for different instruments
- **Precise timing** with scheduled MIDI events
- **Note-on/Note-off** event handling

### File Format Support

- **.mscz**: MuseScore compressed files (ZIP archives containing MusicXML)
- **.musicxml/.xml**: Standard MusicXML format
- **.mid/.midi**: Standard MIDI files

---

## 🌱 Future Enhancements (Roadmap)

### 🎼 Planned Features

| Priority | Feature                 | Description                                                      |
|----------|------------------------|------------------------------------------------------------------|
| High     | 🧭 **Notation Display**  | Visual score rendering with staff notation                       |
| High     | 🎹 **Piano Roll View**   | Alternative visualization showing notes as bars                  |
| Medium   | 📄 **Page Navigation**   | Multi-page scores with zoom and pan                             |
| Medium   | 🎧 **Export Options**    | Export to MIDI, MusicXML, or PDF                               |
| Medium   | ⏱ **Metronome**         | Built-in metronome for practice                                 |
| Low      | ☁️ **iCloud Sync**       | Sync library across devices                                     |
| Low      | ✏️ **Score Editing**     | Basic note editing capabilities                                  |
| Low      | 🎙 **Voice Input**       | Convert humming/singing to notation                             |

### 🔧 Technical Improvements

- **Full ZIP parsing** for complete .mscz support
- **Advanced MusicXML parsing** with chord support
- **Custom notation renderer** using Core Graphics
- **Audio recording** and practice features
- **Haptic feedback** for better user experience

---

## 🐛 Known Limitations

1. **ZIP Extraction**: Currently uses simplified ZIP handling (production apps should use ZIPFoundation)
2. **MusicXML Parsing**: Basic implementation - complex scores may not render perfectly
3. **Sound Fonts**: Uses system default sounds (bundle custom sound fonts for better quality)
4. **Notation Display**: Currently shows placeholder - visual score rendering coming soon

---

## 🛠 Development Notes

### Adding New Features

1. **Models**: Extend `MusicScore.swift` for new data types
2. **Services**: Add business logic to service layer
3. **Views**: Create SwiftUI views with proper state management
4. **MIDI**: Extend `MIDIPlayer.swift` for new audio features

### Testing

- **Use the demo score** that's automatically created on first launch
- **Import sample files** from MuseScore's website
- **Test on both iPhone and iPad** for responsive design

### Deployment

1. **Configure signing** in Xcode project settings
2. **Set deployment target** to iOS 15.0+
3. **Test thoroughly** on real devices
4. **Submit to App Store** following Apple's guidelines

---

## 📄 License

This project is created as a demonstration of iOS music app development. Feel free to use as a starting point for your own music applications.

---

## 🤝 Contributing

This is a complete, working iOS app that demonstrates:
- ✅ File handling and document picker integration
- ✅ MIDI playback with CoreMIDI and AVAudioEngine
- ✅ SwiftUI interface design for iPhone and iPad
- ✅ Music file parsing (basic MusicXML support)
- ✅ Local data persistence
- ✅ Modern iOS development practices

The app is ready to run and can be extended with additional features as needed!
- **Swift Package Manager (SPM)** for managing libraries

---

## 🐳 Development Setup

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/MusePlay.git
   cd MusePlay
````

2. **Open in Xcode:**

   Open `MusePlay.xcodeproj` or `MusePlay.xcworkspace`

3. **Run on Simulator or Device:**

   Make sure your device runs iOS/iPadOS 15+

---

## 📦 Folder Structure

```
MusePlay/
├── Sources/
│   ├── Views/         # SwiftUI UI components
│   ├── MIDI/          # MIDI player and synthesis
│   └── Parser/        # .mscz and MusicXML extraction logic
├── Resources/
│   └── Assets.xcassets
├── Info.plist
└── README.md
```

---

## 🐳 Optional: Docker for Backend Tools

While iOS apps can't run in Docker, you can build CLI tools or backend services in Python to pre-process `.mscz` files:

```dockerfile
# Dockerfile (optional backend service)
FROM python:3.10-slim
RUN pip install music21
COPY process.py .
CMD ["python", "process.py"]
```

---

## ⚙️ CI/CD with GitHub Actions

You can configure CI workflows for linting and building with this:

```yaml
# .github/workflows/ios-build.yml
name: iOS Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Xcode
      uses: maxim-lobanov/setup-xcode@v1
      with:
        xcode-version: '15.0'
    - name: Build app
      run: xcodebuild clean build -project MusePlay.xcodeproj -scheme MusePlay -sdk iphoneos
```

---

## 📩 Contributing

Feel free to fork the repo and submit pull requests! This project is open to collaborations from musicians and developers alike.

---

## 📄 License

MIT License. © 2025 YourName.

