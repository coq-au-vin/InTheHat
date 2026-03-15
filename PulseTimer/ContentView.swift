import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var workoutManager: WorkoutManager

    var body: some View {
        NavigationStack {
            SetupView()
                .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(isPresented: Binding(
            get: { workoutManager.isWorkoutActive || workoutManager.state == .finished },
            set: { _ in }
        )) {
            ActiveTimerView()
                .environmentObject(workoutManager)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager(
            audioManager: AudioManager(),
            notificationManager: NotificationManager()
        ))
        .environmentObject(AudioManager())
}
