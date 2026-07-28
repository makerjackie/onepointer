import SwiftUI

struct InputMonitoringPermissionRow: View {
    @ObservedObject var appModel: AppModel

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .center, spacing: DesignTokens.controlSpacing) {
                permissionDescription
                Spacer()
                permissionButton
            }

            VStack(alignment: .leading, spacing: DesignTokens.controlSpacing) {
                permissionDescription
                permissionButton
            }
        }
        .padding(DesignTokens.controlSpacing)
    }

    private var permissionDescription: some View {
        Label {
            Text(permissionMessage)
        } icon: {
            Image(systemName: "exclamationmark.shield")
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }

    private var permissionMessage: LocalizedStringKey {
        switch appModel.inputMonitoringState {
        case .notDetermined:
            "Allow OnePointer to recognize the double-tap shortcut."
        case .denied:
            "Turn on OnePointer in System Settings, then return here."
        case .granted:
            "Input Monitoring is ready."
        }
    }

    @ViewBuilder
    private var permissionButton: some View {
        switch appModel.inputMonitoringState {
        case .notDetermined:
            Button(
                "Continue & Allow",
                systemImage: "hand.raised.fill",
                action: appModel.requestInputMonitoring
            )
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        case .denied:
            Button(
                "Open System Settings",
                systemImage: "gear",
                action: appModel.openInputMonitoringSettings
            )
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        case .granted:
            EmptyView()
        }
    }
}
