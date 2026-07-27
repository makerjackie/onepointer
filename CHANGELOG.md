# Changelog

All notable changes to OnePointer will be documented here.

## [Unreleased]

## [0.3.0] - 2026-07-27

### Added

- A prominent full-width control for enabling and disabling persistent pointer
  highlighting.
- A compact One Apps link for discovering more utilities from OneApps.Studio.

### Changed

- Redesigned the settings window around two focused destinations: Quick Focus
  and Persistent Highlight.
- Kept all controls visible instead of hiding advanced options behind
  disclosure sections.
- Moved launch-at-login, update, frame-rate, and reset controls into the Quick
  Focus page so a separate General tab is no longer needed.
- Refreshed the app icon with a clearly recognizable pointer and focus ring.

## [0.2.0] - 2026-07-27

### Added

- A configurable double-modifier quick-focus shortcut with separate left and
  right `Option`, `Control`, `Command`, and `Shift` choices.
- An option to disable the quick-focus gesture completely.

### Changed

- The default quick-focus shortcut is now double-tap left `Option`.
- Modifier keys only trigger quick focus when tapped by themselves, preventing
  shortcuts such as `Option` plus another key from causing the effect.

## [0.1.1] - 2026-07-27

### Changed

- The transient focus spotlight now begins as a large circle, rapidly contracts
  toward the pointer, lightly rebounds, settles, and fades within 0.85 seconds.
- Reduce Motion keeps the spotlight at its final size and uses opacity only.

## [0.1.0] - 2026-07-26

First public OnePointer release.

### Added

- Double-tap Control quick focus with a transient, multi-display spotlight.
- A regular, localized SwiftUI settings window with no menu-bar item.
- Optional launch at login using `SMAppService`.
- English and Simplified Chinese localization.
- Unit tests for gesture recognition, animation timing, and display geometry.
- Secure automatic updates with Sparkle 2.9.2.

### Preserved from mac-mouse-highlighter

- Circle, spotlight, ring, crosshair, and pulse presentation styles.
- Ripple, color-flash, and shrink-and-bounce click effects.
- Multi-display overlays, adjustable appearance, and frame-rate controls.
- Permission-free `⌃⌥⌘H` presentation-mode shortcut.
