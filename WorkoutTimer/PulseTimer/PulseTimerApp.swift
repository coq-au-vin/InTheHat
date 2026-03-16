import SwiftUI

@main
struct PulseTimerApp: App {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var workoutManager: WorkoutManager
    @StateObject private var savedWorkoutsManager = SavedWorkoutsManager()

    init() {
        let audio = AudioManager()
        let notifications = NotificationManager()
        let workout = WorkoutManager(audioManager: audio, notificationManager: notifications)
        _audioManager = StateObject(wrappedValue: audio)
        _notificationManager = StateObject(wrappedValue: notifications)
        _workoutManager = StateObject(wrappedValue: workout)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .environmentObject(notificationManager)
                .environmentObject(workoutManager)
                .environmentObject(savedWorkoutsManager)
                .task {
                    audioManager.configureSession()
                    _ = await notificationManager.requestPermission()
                }
        }
    }
}
