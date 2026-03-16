import SwiftUI

struct RoundSummaryView: View {
    @EnvironmentObject var vm: GameViewModel

    private var currentTeam: Team? {
        guard vm.currentTeamIndex < vm.teams.count else { return nil }
        return vm.teams[vm.currentTeamIndex]
    }

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 6) {
                        Text("Round Over!")
                            .font(.roundedSize(32))
                            .foregroundStyle(Color.theme.textPrimary)
                            .padding(.top, 48)
                        if let team = currentTeam {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.teamColor(team.colorName))
                                    .frame(width: 10, height: 10)
                                Text(team.name)
                                    .font(.rounded(.headline))
                                    .foregroundStyle(Color.teamColor(team.colorName))
                            }
                            Text("guessed \(vm.guessedThisRound.count) name\(vm.guessedThisRound.count == 1 ? "" : "s")")
                                .font(.monoStats(.subheadline))
                                .foregroundStyle(Color.theme.textSecondary)
                            Text("Described by \(vm.currentDescriberName)")
                                .font(.monoStats(.caption))
                                .foregroundStyle(Color.theme.textSecondary)
                        }
                    }

                    // Guessed names
                    if !vm.guessedThisRound.isEmpty {
                        CardSection(title: "GUESSED THIS ROUND") {
                            ForEach(Array(vm.guessedThisRound.enumerated()), id: \.offset) { i, name in
                                VStack(spacing: 0) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.theme.rest)
                                        Text(name)
                                            .font(.rounded(.body, weight: .regular))
                                            .foregroundStyle(Color.theme.textPrimary)
                                        Spacer()
                                    }
                                    .padding(.vertical, 13)
                                    .padding(.horizontal, 16)
                                    if i < vm.guessedThisRound.count - 1 {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Leaderboard
                    CardSection(title: "LEADERBOARD") {
                        ForEach(Array(vm.sortedTeams.enumerated()), id: \.element.id) { rank, team in
                            VStack(spacing: 0) {
                                leaderboardRow(rank: rank + 1, team: team)
                                if rank < vm.sortedTeams.count - 1 {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    if vm.hat.isEmpty {
                        Text("🎩 The hat is empty!")
                            .font(.rounded(.subheadline, weight: .regular))
                            .foregroundStyle(Color.theme.textSecondary)
                    }

                    PrimaryButton(
                        title: vm.hat.isEmpty ? "See Final Results" : "Next Team's Turn →",
                        action: vm.nextTurn
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    @ViewBuilder
    private func leaderboardRow(rank: Int, team: Team) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.monoStats(.subheadline))
                .foregroundStyle(Color.theme.textSecondary)
                .frame(width: 20, alignment: .trailing)

            Circle()
                .fill(Color.teamColor(team.colorName))
                .frame(width: 10, height: 10)

            Text(team.name)
                .font(.rounded(.body))
                .foregroundStyle(Color.theme.textPrimary)

            Spacer()

            Text("\(team.score)")
                .font(.rounded(.title3))
                .foregroundStyle(Color.teamColor(team.colorName))
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 16)
    }
}
