# Contributing to Mac Mouse Highlighter

Thank you for your interest in contributing to Mac Mouse Highlighter! This document provides guidelines and information for contributors.

## How to Contribute

### Reporting Bugs

1. Check if the bug has already been reported in [Issues](../../issues)
2. If not, create a new issue using the bug report template
3. Include:
   - macOS version
   - Mac model (Intel or Apple Silicon)
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

### Suggesting Features

1. Check existing [Issues](../../issues) for similar suggestions
2. Create a new issue using the feature request template
3. Describe the use case and why it would be valuable

### Pull Requests

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test thoroughly on macOS
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request

## Code Style Guidelines

### Swift

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation
- Use `// MARK: -` comments to organize code sections
- Prefer `let` over `var` when possible
- Use meaningful variable and function names

### Project Structure

```
MouseHighlighter/
├── App/           # App lifecycle, main entry point
├── Core/          # Core functionality (permissions, settings, events)
├── Overlay/       # Overlay window and view management
├── Highlights/    # Highlight style implementations
├── ClickEffects/  # Click effect implementations
├── UI/            # SwiftUI views and menu bar
└── Resources/     # Assets, icons
```

### Adding New Highlight Styles

1. Create a new Swift file in `Highlights/`
2. Implement the drawing logic
3. Add the style to `HighlightStyle` enum in `SettingsManager.swift`
4. Add UI for any style-specific settings
5. Update the `HighlightView.swift` to render the new style

### Adding New Click Effects

1. Create a new Swift file in `ClickEffects/`
2. Implement the animation logic
3. Add the effect to `ClickEffect` enum in `SettingsManager.swift`
4. Update `AnimationController.swift` to handle the new effect

## Testing

Before submitting a PR:

1. Test on both Intel and Apple Silicon Macs if possible
2. Test all highlight styles and click effects
3. Test across multiple displays
4. Verify settings persistence across app restarts
5. Check for memory leaks using Instruments

## Building from Source

### Requirements

- Xcode 15.0 or later
- macOS 12.0 (Monterey) or later

### Steps

```bash
# Clone the repository
git clone https://github.com/yourusername/mac-mouse-highlighter.git
cd mac-mouse-highlighter

# Open in Xcode
open MouseHighlighter.xcodeproj

# Build and run (Cmd+R)
```

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Feel free to open an issue for any questions about contributing.
