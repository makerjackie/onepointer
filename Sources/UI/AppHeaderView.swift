import SwiftUI

struct AppHeaderView: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "scope")
                .font(.system(size: 32))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .frame(width: 48, height: 48)
                .background(.tint.opacity(0.1))
                .clipShape(.rect(cornerRadius: 12))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text("OnePointer")
                    .font(.title2)
                    .bold()
                Text("Find your pointer instantly, or keep it visible while presenting.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
