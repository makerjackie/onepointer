import SwiftUI

struct PresentationSection: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.sectionSpacing) {
            SettingsPageHeader(
                title: "Presentation Mode",
                subtitle: "Keep the pointer clear and visible during presentations and recordings."
            )

            VStack(alignment: .leading, spacing: DesignTokens.controlSpacing) {
                Button {
                    settings.isEnabled.toggle()
                } label: {
                    HStack(spacing: 14) {
                        Image(
                            systemName: settings.isEnabled
                                ? "checkmark.circle.fill"
                                : "cursorarrow.rays"
                        )
                        .font(.title2)
                        .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(
                                settings.isEnabled
                                    ? "Persistent Highlight Is On"
                                    : "Enable Persistent Highlight"
                            )
                            .font(.headline)

                            Text(
                                settings.isEnabled
                                    ? "Click to turn it off."
                                    : "Keep the pointer visible during presentations and recordings."
                            )
                            .font(.callout)
                            .opacity(0.82)
                        }

                        Spacer()

                        Image(systemName: settings.isEnabled ? "power" : "play.fill")
                            .accessibilityHidden(true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(settings.isEnabled ? Color.green : Color.accentColor)

                Text("Toggle anytime with \(HotKeyManager.shortcutDescription).")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                HighlightPreviewView(settings: settings)

                Picker("Highlight style", selection: $settings.highlightStyle) {
                    ForEach(HighlightStyle.allCases, id: \.self) { style in
                        Text(style.localizedName).tag(style)
                    }
                }
                .pickerStyle(.segmented)

                ColorPicker(
                    "Highlight color",
                    selection: highlightColorBinding,
                    supportsOpacity: false
                )

                LabeledContent("Size") {
                    Slider(value: $settings.highlightSize, in: 20...180, step: 1)
                        .frame(minWidth: 260)
                }

                LabeledContent("Opacity") {
                    Slider(value: $settings.highlightOpacity, in: 0.1...1, step: 0.05)
                        .frame(minWidth: 260)
                }

                styleSpecificControls

                Divider()

                Toggle("Show click effects", isOn: $settings.isClickEffectEnabled)

                Picker("Click effect", selection: $settings.clickEffect) {
                    ForEach(ClickEffect.allCases, id: \.self) { effect in
                        Text(effect.localizedName).tag(effect)
                    }
                }
                .disabled(!settings.isClickEffectEnabled)

                LabeledContent("Effect duration") {
                    Slider(value: $settings.effectDuration, in: 0.1...1, step: 0.05)
                        .frame(minWidth: 260)
                }
                .disabled(!settings.isClickEffectEnabled)
            }
            .padding(DesignTokens.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background)
            .clipShape(.rect(cornerRadius: DesignTokens.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.cardRadius)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.55), lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private var styleSpecificControls: some View {
        switch settings.highlightStyle {
        case .spotlight:
            LabeledContent("Dim opacity") {
                Slider(value: $settings.spotlightDimOpacity, in: 0.3...0.9, step: 0.05)
                    .frame(minWidth: 260)
            }
        case .ring:
            LabeledContent("Ring thickness") {
                Slider(value: $settings.ringThickness, in: 1...10, step: 0.5)
                    .frame(minWidth: 260)
            }
            LabeledContent("Glow intensity") {
                Slider(value: $settings.ringGlowIntensity, in: 0...1, step: 0.1)
                    .frame(minWidth: 260)
            }
        case .crosshair:
            Picker("Crosshair style", selection: $settings.crosshairStyle) {
                ForEach(CrosshairStyle.allCases, id: \.self) { style in
                    Text(style.localizedName).tag(style)
                }
            }
            LabeledContent("Line length") {
                Slider(value: $settings.crosshairLength, in: 10...100, step: 1)
                    .frame(minWidth: 260)
            }
            LabeledContent("Line thickness") {
                Slider(value: $settings.crosshairThickness, in: 1...10, step: 0.5)
                    .frame(minWidth: 260)
            }
        case .pulse:
            Picker("Pulse speed", selection: $settings.pulseSpeed) {
                ForEach(PulseSpeed.allCases, id: \.self) { speed in
                    Text(speed.localizedName).tag(speed)
                }
            }
            Picker("Pulse intensity", selection: $settings.pulseIntensity) {
                ForEach(PulseIntensity.allCases, id: \.self) { intensity in
                    Text(intensity.localizedName).tag(intensity)
                }
            }
        case .circle:
            EmptyView()
        }
    }

    private var highlightColorBinding: Binding<Color> {
        Binding(
            get: { Color(settings.highlightColor) },
            set: { settings.highlightColor = NSColor($0) }
        )
    }
}
