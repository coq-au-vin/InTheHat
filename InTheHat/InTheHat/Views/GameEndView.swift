import SwiftUI

struct GameEndView: View {
    @EnvironmentObject var vm: GameViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(Color.theme.textPrimary.opacity(0.7))
                            .padding(.top, 52)
                        Text("GAME AWARDS")
                            .font(.roundedSize(32))
                            .tracking(1)
                            .foregroundStyle(Color.theme.textPrimary)
                        Text("The hat is empty!")
                            .font(.rounded(.subheadline, weight: .regular))
                            .foregroundStyle(Color.theme.textSecondary)
                    }

                    // Winning team — full width
                    if let winner = vm.sortedTeams.first {
                        winnerCard(winner)
                            .padding(.horizontal, 20)
                    }

                    // 2-column awards grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NAME AWARDS")
                            .font(.monoStats(.caption))
                            .tracking(1.4)
                            .foregroundStyle(Color.theme.textSecondary)
                            .padding(.horizontal, 20)

                        LazyVGrid(columns: columns, spacing: 12) {
                            if let s = vm.speedsterAward {
                                awardCard(
                                    icon: "⚡",
                                    title: "The Speedster",
                                    subtitle: "Fastest name",
                                    value: s.name,
                                    detail: formatTime(s.time),
                                    accentColor: Color.theme.warning
                                )
                            }
                            if let s = vm.stubbornAward {
                                awardCard(
                                    icon: "🔄",
                                    title: "The Stubborn One",
                                    subtitle: "Most passes",
                                    value: s.name,
                                    detail: "\(s.passes) pass\(s.passes == 1 ? "" : "es")",
                                    accentColor: Color.theme.work
                                )
                            }
                            if let s = vm.longRoadAward {
                                awardCard(
                                    icon: "⏱️",
                                    title: "The Long Road",
                                    subtitle: "Most screen time",
                                    value: s.name,
                                    detail: formatTime(s.time),
                                    accentColor: Color(hex: "A8D0BC")
                                )
                            }
                            if let m = vm.mvpAward {
                                awardCard(
                                    icon: "🌟",
                                    title: "MVP",
                                    subtitle: "Fastest average",
                                    value: m.player,
                                    detail: formatTime(m.avgTime) + " avg",
                                    accentColor: Color.theme.rest
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Final rankings
                    VStack(alignment: .leading, spacing: 8) {
                        Text("FINAL RANKINGS")
                            .font(.monoStats(.caption))
                            .tracking(1.4)
                            .foregroundStyle(Color.theme.textSecondary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            ForEach(Array(vm.sortedTeams.enumerated()), id: \.element.id) { rank, team in
                                VStack(spacing: 0) {
                                    rankRow(rank: rank + 1, team: team)
                                    if rank < vm.sortedTeams.count - 1 {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                        }
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 20)
                    }

                    PrimaryButton(title: "Play Again", action: vm.resetGame)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    KoFiFooter()
                        .padding(.bottom, 8)
                }
            }
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func winnerCard(_ team: Team) -> some View {
        HStack(spacing: 16) {
            Text("🏆")
                .font(.system(size: 36))
            VStack(alignment: .leading, spacing: 4) {
                Text("WINNING TEAM")
                    .font(.monoStats(.caption))
                    .tracking(1.4)
                    .foregroundStyle(Color.teamColor(team.colorName).opacity(0.8))
                Text(team.name)
                    .font(.roundedSize(26))
                    .foregroundStyle(Color.teamColor(team.colorName))
                Text("\(team.score) name\(team.score == 1 ? "" : "s") · \(team.playerNames.joined(separator: ", "))")
                    .font(.monoStats(.caption))
                    .foregroundStyle(Color.theme.textSecondary)
            }
            Spacer()
        }
        .padding(20)
        .background(Color.teamColor(team.colorName).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.teamColor(team.colorName).opacity(0.35), lineWidth: 1.5)
        )
    }

    @ViewBuilder
    private func awardCard(icon: String, title: String, subtitle: String, value: String, detail: String, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(icon)
                    .font(.system(size: 28))
                Spacer()
                Text(detail)
                    .font(.monoStats(.caption))
                    .foregroundStyle(Color.theme.textSecondary)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.rounded(.caption, weight: .bold))
                    .foregroundStyle(accentColor)
                Text(subtitle)
                    .font(.monoStats(.caption))
                    .foregroundStyle(Color.theme.textSecondary)
            }
            Text(value)
                .font(.rounded(.subheadline))
                .foregroundStyle(Color.theme.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accentColor.opacity(0.25), lineWidth: 1.5)
        )
    }

    @ViewBuilder
    private func rankRow(rank: Int, team: Team) -> some View {
        HStack(spacing: 12) {
            Group {
                if rank == 1 { Text("🏆").font(.body) }
                else {
                    Text("\(rank)")
                        .font(.monoStats(.subheadline))
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }
            .frame(width: 24, alignment: .center)
            Circle().fill(Color.teamColor(team.colorName)).frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name).font(.rounded(.body)).foregroundStyle(Color.theme.textPrimary)
                Text(team.playerNames.joined(separator: ", ")).font(.monoStats(.caption)).foregroundStyle(Color.theme.textSecondary)
            }
            Spacer()
            Text("\(team.score)").font(.rounded(.title3)).foregroundStyle(Color.teamColor(team.colorName))
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 16)
    }

    private func formatTime(_ t: TimeInterval) -> String {
        if t < 60 { return String(format: "%.1fs", t) }
        let m = Int(t) / 60; let s = Int(t) % 60
        return "\(m)m \(s)s"
    }
}
