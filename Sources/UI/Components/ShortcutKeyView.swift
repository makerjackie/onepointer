import SwiftUI

struct ShortcutKeyView: View {
    let label: String
    let accessibilityLabel: String

    var body: some View {
        Text(label)
            .font(.system(.body, design: .rounded).bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.quaternary)
            .clipShape(.rect(cornerRadius: 8))
            .accessibilityLabel(accessibilityLabel)
    }
}
