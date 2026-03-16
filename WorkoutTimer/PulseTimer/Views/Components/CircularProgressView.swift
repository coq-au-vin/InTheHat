import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    var lineWidth: CGFloat = 12
    var progressColor: Color = Color.theme.textPrimary
    var trackColor: Color = Color.theme.textPrimary.opacity(0.12)

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.65)
        .frame(width: 200, height: 200)
        .padding()
        .background(Color.theme.work)
}
