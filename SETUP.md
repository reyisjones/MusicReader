# 🚀 Quick Setup Guide

Follow these steps to get MusicReader running on your iOS device or simulator.

## Prerequisites ✅

1. **macOS 13.0+**
2. **Xcode 15.0+** (download from App Store or Apple Developer)
3. **iOS 15.0+** target device or simulator

## Setup Steps 📲

### 1. Open the Project
```bash
# Navigate to the project directory
cd /Users/reyisnieves/Dev/MusicReader

# Open in Xcode
open MusicReader.xcodeproj
```

### 2. Configure Build Settings
1. In Xcode, select the **MusicReader** project in the navigator
2. Select the **MusicReader** target
3. In the **Signing & Capabilities** tab:
   - Choose your **Team** (Apple ID or Developer Account)
   - Xcode will automatically generate a Bundle Identifier

### 3. Choose Your Device
- **For Simulator**: Select any iPhone or iPad simulator from the device menu
- **For Physical Device**: Connect your device and select it from the menu

### 4. Build and Run
- Press **⌘ + R** or click the **Play** button
- Wait for the build to complete (first build may take longer)
- The app will launch automatically

## Testing the App 🎵

### With Sample Data
The app automatically creates a demo score on first launch, so you can immediately test playback features.

### With Real Files
1. **Download sample files**:
   - MuseScore files: [musescore.com](https://musescore.com)
   - MusicXML files: [musicxml.com](https://www.musicxml.com/music-in-musicxml/)
   - MIDI files: Various online MIDI libraries

2. **Import methods**:
   - **iPhone**: Tap "Import Music File" → Select from Files app
   - **iPad**: Drag and drop files directly into the app, or use import button

### Key Features to Test
- ✅ **File Import**: Try .mscz, .musicxml, and .mid files
- ✅ **Playback**: Play, pause, stop, seek controls
- ✅ **Tempo**: Adjust playback speed
- ✅ **Volume**: Control audio level
- ✅ **Loop**: Toggle repeat playback
- ✅ **Library**: View all imported scores

## Troubleshooting 🔧

### Build Errors
- **"No Team Selected"**: Configure signing in project settings
- **"iOS Version Not Supported"**: Update deployment target in build settings
- **"Command Line Tools"**: Install full Xcode from App Store (not just command line tools)

### Runtime Issues
- **No Audio**: Check device volume and silent mode
- **File Import Fails**: Ensure file format is supported (.mscz, .musicxml, .mid)
- **App Crashes**: Check device iOS version (requires 15.0+)

### Performance Tips
- **Real Device Recommended**: Audio works better on physical devices
- **iPad Experience**: Drag and drop functionality works only on iPad
- **Memory**: Close other apps for better performance with large scores

## What's Working ✅

This is a **complete, functional iOS app** with:

- 📱 **Native iOS Interface**: SwiftUI-based, works on iPhone and iPad
- 🎵 **Real MIDI Playback**: Using CoreMIDI and AVAudioEngine
- 📂 **File Handling**: Supports MuseScore (.mscz), MusicXML, and MIDI files
- 🎛 **Full Controls**: Play/pause/stop, seek, tempo, volume, loop
- 💾 **Local Storage**: Automatically saves your music library
- 🔄 **Live UI Updates**: Real-time progress and state updates

## Next Steps 🌟

After getting the basic app running, you can:

1. **Add Custom Sound Fonts**: Bundle .sf2 files for better audio quality
2. **Implement Score Display**: Add visual notation rendering
3. **Enhanced File Parsing**: Improve MusicXML and ZIP handling
4. **Export Features**: Add MIDI/PDF export capabilities
5. **iCloud Sync**: Enable cross-device library sync

The codebase is well-structured and documented for easy extension!

---

**Happy Music Making! 🎼**
