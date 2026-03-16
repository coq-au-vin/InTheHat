import SwiftUI

struct PlayerNameEntryView: View {
    @EnvironmentObject var vm: GameViewModel
    let playerIndex: Int

    @State private var name = ""
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Player \(playerIndex + 1) of \(vm.settings.numPlayers)")
                        .font(.monoStats(.subheadline))
                        .foregroundStyle(Color.theme.textSecondary)
                    Text("What's your name?")
                        .font(.roundedSize(30))
                        .foregroundStyle(Color.theme.textPrimary)
                }

                TextField("Enter your name", text: $name)
                    .font(.rounded(.title3, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.theme.textPrimary)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 40)
                    .focused($focused)
                    .onSubmit { submit() }

                PrimaryButton(title: "Next →", action: submit, enabled: isValid)
                    .padding(.horizontal, 40)

                Spacer()
            }
        }
        .onAppear { focused = true }
    }

    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        vm.submitPlayerName(trimmed, forIndex: playerIndex)
    }
}
