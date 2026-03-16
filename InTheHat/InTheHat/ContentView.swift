import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: GameViewModel

    var body: some View {
        ZStack {
            switch vm.phase {
            case .setup:
                SetupView()
            case .enteringPlayerName(let i):
                PlayerNameEntryView(playerIndex: i)
            case .enteringNames(let i):
                NamesEntryView(playerIndex: i, namesPerPlayer: vm.settings.namesPerPlayer)
            case .passingPhone(let i):
                PassPhoneView(completedPlayerIndex: i)
            case .teamReveal:
                TeamRevealView()
            case .getReady:
                GetReadyView()
            case .playing:
                GameView()
            case .roundSummary:
                RoundSummaryView()
            case .gameEnd:
                GameEndView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.phase)
    }
}
