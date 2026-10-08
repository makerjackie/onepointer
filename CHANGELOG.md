# Changelog

All notable changes to OnePointer will be documented here.

## [Unreleased]

### Added

- An optional menu-bar mode. Turn on “Hide the Dock and show in the menu bar” in
  App Settings and OnePointer disappears from the Dock and from ⌘⇥, keeping an
  icon at the right of the menu bar instead; clicking it opens the settings window
  or quits the app.

### Changed

- Dock and ⌘⇥ visibility now follows the “Hide the Dock and show in the menu bar”
  setting, which defaults to off so existing installations keep the regular Dock
  app behaviour. The previous, never-surfaced `showInDock` preference was removed.
- The menu-bar icon is now registered under a OnePointer-specific name instead of
  the auto-assigned one every unnamed status item gets. Without it, macOS stores
  the icon's menu bar position and visibility in a namespace shared with other
  apps, so the spot you drag the icon to was not guaranteed to be remembered.
- The menu-bar icon shows a pointer inside the focus ring, matching the app icon,
  instead of a dot in the middle of the ring.

### Fixed

- Turning “Hide the Dock and show in the menu bar” off used to add the menu bar
  icon and turning it on used to remove it: every click was acted on with the value
  of the previous click, so the icon trailed the checkbox. It now follows the click
  itself.
- The same mistake affected the Quick Focus shortcut toggle: the double-tap
  monitor and the Input Monitoring explanation it triggers were one click behind
  the switch, so enabling the shortcut could leave it without effect until the
  app was relaunched.

## [0.3.1] - 2026-07-28

### Added

- A concise first-run explanation before requesting Input Monitoring.
- A “Not Now” path that keeps permission-free features available.

### Fixed

- Input Monitoring now uses the system HID authorization API so macOS registers
  OnePointer in the permission list without requiring users to find the app
  manually with the `+` button.
- The permission card now shows one clear next action for each authorization
  state instead of two competing buttons.

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
