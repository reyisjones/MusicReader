#!/bin/bash

# MusicReader Build Script
# This script helps you build and run the MusicReader iOS app

echo "🎼 MusicReader Build Script"
echo "=========================="

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "MusicReader.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: MusicReader.xcodeproj not found"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "✅ Found MusicReader project"

# Build the project
echo "🔨 Building MusicReader for iOS Simulator..."
xcodebuild -project MusicReader.xcodeproj \
           -scheme MusicReader \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=latest' \
           build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🚀 To run the app:"
    echo "1. Open MusicReader.xcodeproj in Xcode"
    echo "2. Select your target device (iPhone/iPad or Simulator)"
    echo "3. Press Cmd+R to build and run"
    echo ""
    echo "📱 Supported devices:"
    echo "- iPhone (iOS 15.0+)"
    echo "- iPad (iPadOS 15.0+)"
    echo ""
    echo "🎵 Supported file formats:"
    echo "- .mscz (MuseScore files)"
    echo "- .musicxml/.xml (MusicXML files)"
    echo "- .mid/.midi (MIDI files)"
else
    echo "❌ Build failed!"
    echo "Please check the error messages above and fix any issues."
    exit 1
fi
