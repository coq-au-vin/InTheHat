import SwiftUI

struct TimerDisplayView: View {
    let seconds: Int
    var color: Color = Color.theme.textPrimary

    private var formatted: String {
        let m = seconds / 60
        let s = seconds % 60
        if m > 0 {
            return String(format: "%d:%02d", m, s)
        } else {
            return "\(s)"
        }
    }

    var body: some View {
        Text(formatted)
            .font(.dinTimer(size: 96))
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .animation(.default, value: seconds)
    }
}

#Preview {
    TimerDisplayView(seconds: 42)
        .padding()
        .background(Color.theme.work)
}
