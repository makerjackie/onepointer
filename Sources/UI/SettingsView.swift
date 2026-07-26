import SwiftUI

struct SettingsView: View {
    @ObservedObject var appModel: AppModel
    @ObservedObject var settings: SettingsManager

    @State private var showsPresentationDetails = false
    @State private var showsAdvancedSettings = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.sectionSpacing) {
                AppHeaderView()
                QuickFocusSection(appModel: appModel, settings: settings)
                PresentationSection(
                    settings: settings,
                    isExpanded: $showsPresentationDetails
                )
                AdvancedSettingsSection(
                    settings: settings,
                    isExpanded: $showsAdvancedSettings
                )
            }
            .padding(DesignTokens.pagePadding)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .alert(
            "Unable to update login item",
            isPresented: launchAtLoginAlertBinding
        ) {
            Button("OK", action: settings.clearLaunchAtLoginError)
        } message: {
            Text(settings.launchAtLoginError ?? "")
        }
    }

    private var launchAtLoginAlertBinding: Binding<Bool> {
        Binding(
            get: { settings.launchAtLoginError != nil },
            set: { isPresented in
                if !isPresented {
                    settings.clearLaunchAtLoginError()
                }
            }
        )
    }
}

#Preview {
    SettingsView(
        appModel: AppModel(),
        settings: SettingsManager.shared
    )
    .frame(width: 720, height: 700)
}
