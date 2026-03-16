import SwiftUI

@main
struct InTheHatApp: App {
    @StateObject private var vm = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .onAppear {
                    vm.loadState()
                    vm.resumeTimerIfNeeded()
                }
        }
    }
}
