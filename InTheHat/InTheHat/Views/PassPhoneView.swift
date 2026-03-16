import SwiftUI

struct PassPhoneView: View {
    @EnvironmentObject var vm: GameViewModel
    let completedPlayerIndex: Int

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                BaseballCapView(size: 72, color: Color.theme.accent)

                VStack(spacing: 10) {
                    Text("Thank you, \(vm.currentPlayerName)!")
                        .font(.roundedSize(28))
                        .foregroundStyle(Color.theme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Pass the phone to\nPlayer \(completedPlayerIndex + 2)")
                        .font(.rounded(.title3, weight: .regular))
                        .foregroundStyle(Color.theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                PrimaryButton(title: "I'm Ready →") {
                    vm.advanceFromPassPhone(playerIndex: completedPlayerIndex)
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}
