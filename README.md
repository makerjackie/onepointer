# OnePointer

[简体中文](#简体中文) · [English](#english)

OnePointer is a native, open-source macOS utility for finding and presenting the
mouse pointer. It keeps the original presentation features from
`mac-mouse-highlighter` and adds a restrained, transient spotlight triggered by
double-tapping Control.

## 简体中文

### 功能

- 双击同一侧 `Control`：所有显示器短暂变暗，在鼠标位置显示聚光圈并淡出
- “立即聚焦指针”按钮：无需输入监控权限即可测试聚焦效果
- 演示模式：圆形、聚光灯、圆环、十字准星、脉冲五种持续高亮
- 点击效果：涟漪、颜色闪光、收缩回弹
- 多显示器与全屏空间支持
- `⌃⌥⌘H`：随时开关演示模式
- 可选开机启动，默认关闭
- Sparkle 安全自动更新，也可手动“检查更新”
- 简体中文与英文界面

OnePointer 是普通 Dock App，不创建菜单栏图标。关闭设置窗口后，App
仍会在后台运行；再次从 Spotlight 或“应用程序”打开即可显示窗口。

### 权限

只有“双击 Control”需要 macOS 的“输入监控”权限，用于只读识别按键节奏。
聚焦按钮、`⌃⌥⌘H` 和鼠标演示模式不需要该权限。OnePointer 的事件监听使用
`.listenOnly`，不会注入、修改或拦截输入。

首次使用双击 Control：

1. 打开 OnePointer。
2. 点击“允许输入监控”。
3. 在“系统设置 → 隐私与安全性 → 输入监控”中启用 OnePointer。
4. 返回 OnePointer；如 macOS 要求，退出并重新打开 App。

### 从 GitHub Releases 安装

1. 从 [GitHub Releases](https://github.com/makerjackie/onepointer/releases) 下载最新的 `.dmg`。
2. 打开 DMG，将 OnePointer 拖入“应用程序”。
3. 打开 OnePointer，并按上面的说明授权“双击 Control”。

公开 Release 使用 Developer ID Application 签名，经过 Apple 公证并附加
notarization ticket。后续版本可由 App 内的 Sparkle 安全更新。

### 从源码构建

要求 macOS 13 或更高版本、Xcode 26 或兼容版本，以及
[XcodeGen](https://github.com/yonaskolb/XcodeGen)。

```bash
xcodegen generate
xcodebuild test \
  -project OnePointer.xcodeproj \
  -scheme OnePointer \
  -configuration Debug \
  -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO
```

本地独立仓库路径建议为 `/Users/jackiexiao/code/OnePointer`。它不属于
`/Users/jackiexiao/code/OneApps` monorepo。

维护者可运行 `./scripts/build-dmg.sh` 完成测试、归档、嵌套签名、App 与
DMG 双重公证、Sparkle appcast 签名和校验和生成。

## English

### Features

- Double-tap the same `Control` key to briefly dim every display and reveal a
  fading spotlight at the pointer
- A “Focus Pointer Now” button that previews the effect without Input
  Monitoring permission
- Presentation mode with circle, spotlight, ring, crosshair, and pulse styles
- Ripple, color-flash, and shrink-and-bounce click effects
- Multiple-display and full-screen Space support
- `⌃⌥⌘H` toggles presentation mode
- Optional launch at login, off by default
- Secure Sparkle automatic updates and a manual “Check for Updates” action
- Full English and Simplified Chinese interface

OnePointer is a regular Dock app and does not create a menu-bar item. Closing
the settings window leaves the app running; open it again from Spotlight or
Applications to bring the window back.

### Permission

Only the double-Control gesture needs macOS Input Monitoring, solely to observe
the key rhythm. The focus button, `⌃⌥⌘H`, and presentation mode do not require
it. The event tap is listen-only and cannot inject, modify, or block input.

### Install from GitHub Releases

1. Download the latest `.dmg` from
   [GitHub Releases](https://github.com/makerjackie/onepointer/releases).
2. Open the DMG and drag OnePointer to Applications.
3. Launch OnePointer and grant Input Monitoring if you want double-Control.

Public releases are Developer ID signed, notarized by Apple, and stapled.
Future releases can be installed securely by Sparkle from inside the app.

### Build from source

OnePointer requires macOS 13 or later, Xcode 26 or a compatible release, and
[XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
xcodegen generate
xcodebuild test \
  -project OnePointer.xcodeproj \
  -scheme OnePointer \
  -configuration Debug \
  -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO
```

## License and upstream attribution

OnePointer is licensed under the MIT License. It contains modified source and
assets from Nikhil Bhansali's
[`mac-mouse-highlighter`](https://github.com/nikhilbhansali/mac-mouse-highlighter)
at commit `385412eeb4c75b272a19b4eda1d7ae739c8f7b85`, also licensed under MIT.
The required upstream notice is preserved in
[`LICENSES/mac-mouse-highlighter-LICENSE`](LICENSES/mac-mouse-highlighter-LICENSE)
and [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md). Sparkle's complete
license notices are preserved in [`LICENSES/Sparkle-LICENSE`](LICENSES/Sparkle-LICENSE).
