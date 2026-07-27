import SwiftUI

struct FocusPreviewSurface: View {
    var body: some View {
        ZStack {
            FocusPreviewGrid()

            Circle()
                .fill(.yellow.opacity(0.16))
                .frame(width: 150, height: 150)
                .blur(radius: 18)

            Circle()
                .stroke(Color.accentColor.opacity(0.14), lineWidth: 18)
                .frame(width: 122, height: 122)

            Circle()
                .stroke(Color.accentColor, lineWidth: 4)
                .frame(width: 74, height: 74)
                .shadow(color: .accentColor.opacity(0.28), radius: 12)

            Image(systemName: "cursorarrow")
                .font(.system(size: 34, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color(nsColor: .labelColor), .white)
                .offset(x: 7, y: -4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 198)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(.rect(cornerRadius: DesignTokens.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.cardRadius)
                .stroke(Color(nsColor: .separatorColor).opacity(0.5), lineWidth: 1)
        }
        .accessibilityHidden(true)
    }
}
