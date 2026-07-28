import SwiftUI

struct InputMonitoringOnboardingView: View {
    let continueAction: () -> Void
    let notNowAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.sectionSpacing) {
            header

            Divider()

            VStack(alignment: .leading, spacing: DesignTokens.controlSpacing) {
                InputMonitoringPermissionStep(
                    number: 1,
                    title: "Continue to let macOS add OnePointer to Input Monitoring."
                )
                InputMonitoringPermissionStep(
                    number: 2,
                    title: "Turn on the switch beside OnePointer in System Settings."
                )
            }

            Label(
                "OnePointer observes only the input events needed to recognize the modifier-key rhythm. It never records typed text or changes your input.",
                systemImage: "lock.shield"
            )
            .font(.callout)
            .foregroundStyle(.secondary)

            HStack {
                Button("Not Now", action: notNowAction)
                    .keyboardShortcut(.cancelAction)

                Spacer()

                Button(
                    "Continue & Allow",
                    systemImage: "hand.raised.fill",
                    action: continueAction
                )
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(DesignTokens.pagePadding)
        .frame(minWidth: 500, idealWidth: 520, maxWidth: 560)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: DesignTokens.controlSpacing) {
            Image(systemName: "cursorarrow.rays")
                .font(.largeTitle)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .frame(width: 52, height: 52)
                .background(.tint.opacity(0.1))
                .clipShape(.rect(cornerRadius: 14))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text("Enable Double-Tap Quick Focus")
                    .font(.title2)
                    .bold()
                Text("OnePointer needs Input Monitoring so the shortcut works while you use other apps.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
