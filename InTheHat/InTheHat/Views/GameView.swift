import SwiftUI

struct GameView: View {
    @EnvironmentObject var vm: GameViewModel

    private var currentTeam: Team? {
        guard vm.currentTeamIndex < vm.teams.count else { return nil }
        return vm.teams[vm.currentTeamIndex]
    }

    private var teamColor: Color {
        Color.teamColor(currentTeam?.colorName ?? "")
    }

    var body: some View {
        ZStack {
            teamColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Team name + hat count
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentTeam?.name ?? "")
                            .font(.rounded(.title2))
                            .foregroundStyle(.white)
                        Text("\(vm.hat.count + (vm.currentName != nil ? 1 : 0)) names left")
                            .font(.monoStats(.caption))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Spacer()
                    // Countdown timer
                    Text("\(vm.timeRemaining)")
                        .font(.dinTimer(size: 72))
                        .foregroundStyle(vm.timeRemaining <= 10 ? Color(hex: "FFECEC") : .white)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.3), value: vm.timeRemaining)
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)

                Spacer()

                // Pass state banner
                passStateBanner

                // Current name
                if let name = vm.currentName {
                    Text(name)
                        .font(.roundedSize(46))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 32)
                        .transition(.scale.combined(with: .opacity))
                        .id(name)
                } else {
                    Text("—")
                        .font(.roundedSize(46))
                        .foregroundStyle(.white.opacity(0.35))
                }

                Spacer()

                // Action buttons
                HStack(spacing: 12) {
                    Button(action: vm.pass) {
                        VStack(spacing: 6) {
                            Image(systemName: passButtonIcon)
                                .font(.title2)
                            Text(passButtonLabel)
                                .font(.rounded(.headline))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.white.opacity(vm.canPass ? 0.18 : 0.08))
                        .foregroundStyle(vm.canPass ? .white : .white.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(!vm.canPass)

                    Button(action: vm.correct) {
                        VStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            Text("Correct!")
                                .font(.rounded(.headline))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.white)
                        .foregroundStyle(teamColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 44)
            }
        }
        .onAppear { vm.resumeTimerIfNeeded() }
    }

    @ViewBuilder
    private var passStateBanner: some View {
        switch vm.passState {
        case .usedOnce(let name):
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("Pass used — tap Pass again to return to \"\(name)\"")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.monoStats(.caption))
            .foregroundStyle(Color.theme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.theme.warning)
            .clipShape(Capsule())
            .padding(.bottom, 16)

        case .locked(let name):
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                Text("Locked on \"\(name)\" — guess it or wait!")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.monoStats(.caption))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.black.opacity(0.35))
            .clipShape(Capsule())
            .padding(.bottom, 16)

        case .none:
            EmptyView()
        }
    }

    private var passButtonLabel: String {
        switch vm.passState {
        case .none:      return "Pass"
        case .usedOnce:  return "Return"
        case .locked:    return "Locked"
        }
    }

    private var passButtonIcon: String {
        switch vm.passState {
        case .none:      return "arrow.right.circle"
        case .usedOnce:  return "arrow.uturn.left.circle"
        case .locked:    return "lock.fill"
        }
    }
}
