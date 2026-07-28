import SwiftUI

struct InputMonitoringPermissionStep: View {
    let number: Int
    let title: LocalizedStringKey

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(number, format: .number)
                .bold()
                .foregroundStyle(.tint)
                .frame(minWidth: 22)
            Text(title)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}
