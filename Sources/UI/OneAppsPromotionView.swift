import SwiftUI

struct OneAppsPromotionView: View {
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Label("More Useful Apps", systemImage: "square.grid.2x2.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentColor)

                Text("Explore lightweight tools for Mac, iPhone, and iPad.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Link(destination: oneAppsURL) {
                Label("Explore One Apps", systemImage: "arrow.up.right")
            }
            .font(.caption)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.045))
        .clipShape(.rect(cornerRadius: DesignTokens.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.cardRadius)
                .stroke(Color.accentColor.opacity(0.14), lineWidth: 1)
        }
        .padding(12)
    }

    private var oneAppsURL: URL {
        let path = locale.identifier.hasPrefix("zh") ? "/zh/apps" : "/apps"
        guard let url = URL(string: "https://oneapps.studio\(path)") else {
            fatalError("One Apps URL literal must remain valid")
        }
        return url
    }
}
