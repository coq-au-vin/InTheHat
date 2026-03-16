import SwiftUI

struct TeamRevealView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        BaseballCapView(size: 64, color: Color.theme.accent)
                            .padding(.top, 56)
                        Text("Meet Your Teams")
                            .font(.roundedSize(30))
                            .foregroundStyle(Color.theme.textPrimary)
                        Text("\(vm.hat.count) names in the hat")
                            .font(.monoStats(.subheadline))
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                    .padding(.bottom, 4)

                    VStack(spacing: 12) {
                        ForEach(vm.teams) { team in
                            teamCard(team)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 24)

                    PrimaryButton(title: "Start Game!", action: vm.startGame)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
    }

    @ViewBuilder
    private func teamCard(_ team: Team) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.teamColor(team.colorName))
                .frame(width: 14, height: 14)
            VStack(alignment: .leading, spacing: 3) {
                Text(team.name)
                    .font(.rounded(.body))
                    .foregroundStyle(Color.theme.textPrimary)
                Text(team.playerNames.joined(separator: ", "))
                    .font(.monoStats(.subheadline))
                    .foregroundStyle(Color.theme.textSecondary)
            }
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.teamColor(team.colorName).opacity(0.4), lineWidth: 2)
        )
    }
}
