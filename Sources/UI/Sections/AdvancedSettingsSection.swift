import SwiftUI

struct AdvancedSettingsSection: View {
    @ObservedObject var settings: SettingsManager
    @Binding var isExpanded: Bool

    var body: some View {
        SettingsCard(title: "General", systemImage: "gearshape") {
            Toggle("Launch OnePointer at login", isOn: $settings.launchAtLogin)

            DisclosureGroup("Advanced", isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: DesignTokens.controlSpacing) {
                    Picker("Presentation frame rate", selection: $settings.targetFrameRate) {
                        Text("30 FPS").tag(30)
                        Text("60 FPS").tag(60)
                    }

                    Button(
                        "Reset to Defaults",
                        action: settings.resetToDefaults
                    )
                }
                .padding(.top, 8)
            }
        }
    }
}
