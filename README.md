# Mac Mouse Highlighter

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-12.0%2B%20Monterey-blue)](https://www.apple.com/macos/)
[![Platform](https://img.shields.io/badge/Platform-Universal%20Binary-green)](https://developer.apple.com/documentation/apple-silicon/building-a-universal-macos-binary)

A native macOS app that adds visual highlights around the mouse cursor and animated click effects, perfect for screen recordings, presentations, and demos.

## Why I Built This

Ever tried to record a tutorial or do a live demo and your audience just... loses your cursor? I've been there countless times. "Where's the mouse?" "Can you click that again?" "I couldn't see where you clicked."

It's such a simple problem, but surprisingly annoying. I just wanted a quick way to highlight my mouse cursor - nothing fancy, just something that works. Most solutions out there were either paid apps with way more features than I needed, or janky utilities that hadn't been updated since 2015.

So I built this. A simple, native Mac app that does one thing well: makes your cursor visible. Whether you're recording a screencast, presenting to your team, or helping someone over a screen share, you'll never lose your cursor again.

It's free, it's open source, and it just works. Hope it helps you as much as it helps me.

## Download

Download the latest release from [GitHub Releases](../../releases).

> **Note:** Since this app is not notarized, macOS will show a security warning. See [Installation](#installation) for how to open it.

## Features

### Highlight Styles
- **Circle** - A soft, filled circle that follows your cursor with gradient effect
- **Spotlight** - Dims the entire screen except for a spotlight around the cursor
- **Ring** - A glowing ring outline around the cursor

### Click Effects
- **Ripple** - An expanding circle that fades out from the click location
- **Color Flash** - A brief flash of color at the click point
- **Shrink & Bounce** - The highlight shrinks then bounces back with a spring effect

### App Features
- Menu bar icon with quick access to settings
- Optional dock icon presence
- Launch at login support
- Customizable colors, sizes, and opacity
- Works across all displays
- Low CPU usage with smooth 60fps animations

## Requirements

- **macOS:** 12.0 (Monterey) or later
- **Architecture:** Universal Binary (Intel & Apple Silicon)
- **Permissions:** Input Monitoring (required for mouse tracking)

## Installation

### From GitHub Releases (Recommended)

1. Download the latest `.dmg` from [Releases](../../releases)
2. Open the DMG and drag the app to Applications
3. **Important:** Right-click the app and select "Open" (required for first launch)
4. Click "Open" in the security dialog
5. Grant Input Monitoring permission when prompted

### Opening Unsigned Apps

Since this app is distributed outside the Mac App Store and is not notarized, macOS Gatekeeper will block it. To open:

**Method 1: Right-click → Open**
1. Right-click (or Control-click) the app
2. Select "Open" from the context menu
3. Click "Open" in the dialog

**Method 2: System Settings**
1. Try to open the app normally (it will be blocked)
2. Go to System Settings → Privacy & Security
3. Scroll down and click "Open Anyway"

## Usage

### Menu Bar
Click the menu bar icon to:
- Toggle the highlighter on/off
- Change highlight style
- Change click effect
- Open settings

### Settings
Access detailed settings through the menu bar or by clicking the dock icon:

**General Tab**
- Enable/disable the highlighter
- Launch at login
- Show/hide dock icon

**Highlight Tab**
- Choose highlight style (Circle, Spotlight, Ring)
- Set highlight color
- Adjust size and opacity
- Style-specific settings (spotlight dim level, ring glow intensity)

**Effects Tab**
- Choose click effect (None, Ripple, Color Flash, Shrink & Bounce)
- Adjust effect duration

## Permissions

Mac Mouse Highlighter requires **Input Monitoring** permission to track mouse movement and clicks. This is a macOS privacy feature that ensures apps can only access this data with your explicit consent.

To grant permission:
1. Go to System Settings → Privacy & Security → Input Monitoring
2. Enable the toggle for Mac Mouse Highlighter
3. Restart the app if needed

### Why is App Sandbox Disabled?

This app requires `CGEventTap` to monitor mouse events globally, which is incompatible with App Sandbox. The app only uses `.listenOnly` mode and cannot inject or modify input events.

## Building from Source

### Prerequisites
- Xcode 15.0 or later
- macOS 12.0 SDK or later

### Steps

```bash
# Clone the repository
git clone https://github.com/yourusername/mac-mouse-highlighter.git
cd mac-mouse-highlighter

# Open in Xcode
open MouseHighlighter.xcodeproj

# Build and run (Cmd+R)
```

### Building Universal Binary

```bash
xcodebuild -project MouseHighlighter.xcodeproj \
  -scheme "MouseHighlighter" \
  -configuration Release \
  -arch arm64 -arch x86_64 \
  ONLY_ACTIVE_ARCH=NO

# Verify architectures
lipo -info "build/Release/Mac Mouse Highlighter.app/Contents/MacOS/Mac Mouse Highlighter"
# Should output: Architectures in the fat file: arm64 x86_64
```

### Generating App Icons

A Swift script is included to generate app icons:
```bash
swift generate_icon.swift MouseHighlighter/Resources/Assets.xcassets/AppIcon.appiconset
```

## Project Structure

```
MouseHighlighter/
├── App/
│   ├── AppDelegate.swift           # App lifecycle, permissions
│   └── Info.plist                  # App configuration
├── Core/
│   ├── MouseEventMonitor.swift     # Global mouse tracking
│   ├── PermissionsManager.swift    # Input Monitoring permissions
│   └── SettingsManager.swift       # UserDefaults persistence
├── Overlay/
│   ├── OverlayWindowController.swift  # Transparent overlay windows
│   ├── HighlightView.swift         # Main rendering view
│   └── AnimationController.swift   # 60fps display link
├── Highlights/
│   ├── CircleHighlight.swift       # Filled circle renderer
│   ├── SpotlightHighlight.swift    # Screen dim with cutout
│   └── RingHighlight.swift         # Glowing ring renderer
├── ClickEffects/
│   ├── RippleEffect.swift          # Expanding fade-out circle
│   ├── ColorFlashEffect.swift      # Brief color change
│   └── ShrinkBounceEffect.swift    # Spring animation
├── UI/
│   ├── MenuBarController.swift     # Status bar icon + dropdown
│   └── SettingsView.swift          # SwiftUI settings window
└── Resources/
    └── Assets.xcassets             # App icons
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and AppKit
- Uses Core Graphics for efficient rendering
- Icon generated programmatically
