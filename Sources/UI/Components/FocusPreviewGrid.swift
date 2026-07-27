import SwiftUI

struct FocusPreviewGrid: View {
    var body: some View {
        Canvas { context, size in
            let spacing = 24.0
            var path = Path()

            var x = spacing
            while x < size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }

            var y = spacing
            while y < size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }

            context.stroke(
                path,
                with: .color(Color(nsColor: .separatorColor).opacity(0.22)),
                lineWidth: 0.5
            )
        }
    }
}
