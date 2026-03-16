import SwiftUI

struct GetReadyView: View {
    @EnvironmentObject var vm: GameViewModel

    private var currentTeam: Team? {
        guard vm.currentTeamIndex < vm.teams.count else { return nil }
        return vm.teams[vm.currentTeamIndex]
    }

    var body: some View {
        ZStack {
            // Team-colored full screen background (matches GameView aesthetic)
            Color.teamColor(currentTeam?.colorName ?? "").ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    // Team badge
                    Text(currentTeam?.name ?? "")
                        .font(.monoStats(.subheadline))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())

                    // Describer name
                    Text(vm.currentDescriberName)
                        .font(.roundedSize(44))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Text("it's your turn to describe!")
                        .font(.rounded(.title3, weight: .regular))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                VStack(spacing: 16) {
                    // Hat count
                    Text("\(vm.hat.count) name\(vm.hat.count == 1 ? "" : "s") left in the hat")
                        .font(.monoStats(.subheadline))
                        .foregroundStyle(.white.opacity(0.7))

                    Button(action: vm.beginRoundFromReady) {
                        Text("Start Round →")
                            .font(.rounded(.title3))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(.white)
                            .foregroundStyle(Color.teamColor(currentTeam?.colorName ?? ""))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 44)
                }
            }
        }
    }
}
