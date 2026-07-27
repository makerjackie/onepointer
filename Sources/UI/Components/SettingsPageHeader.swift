import SwiftUI

struct SettingsPageHeader: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2)
                .bold()

            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}
