import SwiftUI

struct QuickFocusSection: View {
    @ObservedObject var appModel: AppModel
    @ObservedObject var settings: SettingsManager

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.sectionSpacing) {
            SettingsPageHeader(
                title: "Quick Focus",
                subtitle: "Find the pointer instantly with a brief, focused animation."
            )

            FocusPreviewSurface()

            QuickFocusControlBar(
                appModel: appModel,
                settings: settings
            )

            AdvancedSettingsSection(
                appModel: appModel,
                settings: settings
            )
        }
    }
}
