# Contributing to OnePointer

Contributions are welcome and are licensed under the repository's MIT License.

## Build and test

OnePointer targets macOS 13 or later and uses XcodeGen to keep the Xcode project
reproducible.

```bash
xcodegen generate
./scripts/run-tests.sh
```

Before submitting a change, test the relevant behavior on macOS. Visual or input
changes should cover:

- Double-tap Control recognition and cancellation by unrelated input.
- The “Focus Pointer Now” permission-free fallback.
- Every presentation style and click effect affected by the change.
- Multiple displays and a full-screen Space when available.
- English and Simplified Chinese layouts.
- Reduced Motion behavior for transient focus animations.

Keep the app as a regular Dock app without creating a menu-bar status item.
Preserve notices for code and assets derived from `mac-mouse-highlighter`.
