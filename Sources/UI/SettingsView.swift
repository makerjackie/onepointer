import SwiftUI

struct SettingsView: View {
    @ObservedObject var appModel: AppModel
    @ObservedObject var settings: SettingsManager

    @State private var selectedPage: SettingsPage? = .quickFocus

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(SettingsPage.allCases, selection: $selectedPage) { page in
                    Label(page.title, systemImage: page.systemImage)
                        .tag(page)
                }
                .listStyle(.sidebar)

                Divider()

                OneAppsPromotionView()

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Button("Run in Background", systemImage: "menubar.rectangle", action: appModel.runInBackground)
                    Button("Quit OnePointer", systemImage: "power", action: appModel.quit)
                    Text("OnePointer \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 250)
        } detail: {
            ScrollView {
                selectedPageView
                    .frame(maxWidth: 820, alignment: .leading)
                    .padding(30)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .alert(
            "Unable to update login item",
            isPresented: launchAtLoginAlertBinding
        ) {
            Button("OK", action: settings.clearLaunchAtLoginError)
        } message: {
            Text(settings.launchAtLoginError ?? "")
        }
        .sheet(
            isPresented: $appModel.isInputMonitoringOnboardingPresented,
            onDismiss: appModel.acknowledgeInputMonitoringOnboarding
        ) {
            InputMonitoringOnboardingView(
                continueAction: appModel.requestInputMonitoring,
                notNowAction: appModel.acknowledgeInputMonitoringOnboarding
            )
        }
    }

    @ViewBuilder
    private var selectedPageView: some View {
        switch selectedPage ?? .quickFocus {
        case .quickFocus:
            QuickFocusSection(appModel: appModel, settings: settings)
        case .presentation:
            PresentationSection(settings: settings)
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

private enum SettingsPage: String, CaseIterable, Identifiable {
    case quickFocus
    case presentation

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .quickFocus:
            "Quick Focus"
        case .presentation:
            "Presentation Mode"
        }
    }

    var systemImage: String {
        switch self {
        case .quickFocus:
            "scope"
        case .presentation:
            "cursorarrow.rays"
        }
    }
}

#Preview {
    SettingsView(
        appModel: AppModel(),
        settings: SettingsManager.shared
    )
    .frame(width: 980, height: 700)
}
