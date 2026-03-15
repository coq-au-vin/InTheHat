import Foundation
import UIKit

enum TimerState: Equatable {
    case idle
    case work(exercise: Int, round: Int)
    case rest(exercise: Int, round: Int)
    case roundRest(completedRound: Int)
    case finished
}

class WorkoutManager: ObservableObject {
    @Published var config: WorkoutConfiguration = .default
    @Published var state: TimerState = .idle
    @Published var displaySeconds: Int = 0
    @Published var phaseProgress: Double = 0.0
    @Published var isPaused: Bool = false

    var isWorkoutActive: Bool {
        state != .idle && state != .finished
    }

    private let audioManager: AudioManager
    private let notificationManager: NotificationManager

    private var timer: Timer?
    private var phaseStartTime: CFAbsoluteTime = 0
    private var accumulatedPauseTime: CFAbsoluteTime = 0
    private var pauseStartTime: CFAbsoluteTime = 0
    private var phaseDuration: CFAbsoluteTime = 0

    init(audioManager: AudioManager, notificationManager: NotificationManager) {
        self.audioManager = audioManager
        self.notificationManager = notificationManager
    }

    // MARK: - Public Controls

    func startWorkout() {
        config = config  // ensure fresh copy
        let startTime = Date()
        notificationManager.scheduleAllNotifications(for: config, startTime: startTime)
        beginPhase(.work(exercise: 1, round: 1))
    }

    func pause() {
        guard !isPaused, isWorkoutActive else { return }
        isPaused = true
        pauseStartTime = CFAbsoluteTimeGetCurrent()
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard isPaused, isWorkoutActive else { return }
        isPaused = false
        let pauseDuration = CFAbsoluteTimeGetCurrent() - pauseStartTime
        accumulatedPauseTime += pauseDuration
        startTicker()
    }

    func stopWorkout() {
        timer?.invalidate()
        timer = nil
        state = .idle
        isPaused = false
        displaySeconds = 0
        phaseProgress = 0.0
        accumulatedPauseTime = 0
        notificationManager.cancelAllWorkoutNotifications()
        audioManager.stopSilentLoop()
    }

    // MARK: - Phase Management

    private func beginPhase(_ newState: TimerState) {
        state = newState
        isPaused = false
        accumulatedPauseTime = 0
        phaseDuration = CFAbsoluteTime(durationFor(newState))
        // Start 0.5 s in the future so the display holds at full duration briefly
        // before counting down. tick() clamps elapsed to 0 during this window.
        phaseStartTime = CFAbsoluteTimeGetCurrent() + 0.5
        displaySeconds = Int(phaseDuration)
        phaseProgress = 0.0
        startTicker()
    }

    private func startTicker() {
        timer?.invalidate()
        timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func tick() {
        // Clamp to 0 during the start-of-phase hold window (phaseStartTime is in the future)
        let elapsed = max(0, CFAbsoluteTimeGetCurrent() - phaseStartTime - accumulatedPauseTime)
        let remaining = max(0, phaseDuration - elapsed)
        displaySeconds = Int(ceil(remaining))
        phaseProgress = min(1.0, elapsed / phaseDuration)

        if remaining <= 0 {
            // Show "0" for 0.5 s before transitioning so the display clearly hits zero
            timer?.invalidate()
            timer = nil
            displaySeconds = 0
            phaseProgress = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.advancePhase()
            }
        }
    }

    private func advancePhase() {
        timer?.invalidate()
        timer = nil

        triggerTransitionFeedback()

        let nextState = nextPhase(from: state)
        if nextState == .finished {
            state = .finished
            audioManager.stopSilentLoop()
        } else {
            beginPhase(nextState)
        }
    }

    private func nextPhase(from current: TimerState) -> TimerState {
        switch current {
        case .work(let exercise, let round):
            return .rest(exercise: exercise, round: round)

        case .rest(let exercise, let round):
            if exercise < config.exercisesPerRound {
                return .work(exercise: exercise + 1, round: round)
            } else if round < config.rounds {
                return .roundRest(completedRound: round)
            } else {
                return .finished
            }

        case .roundRest(let completedRound):
            return .work(exercise: 1, round: completedRound + 1)

        case .idle, .finished:
            return .finished
        }
    }

    private func durationFor(_ state: TimerState) -> Int {
        switch state {
        case .work:
            return config.workDuration
        case .rest:
            return config.restDuration
        case .roundRest:
            return config.restBetweenRounds
        case .idle, .finished:
            return 0
        }
    }

    private func triggerTransitionFeedback() {
        audioManager.playBeep()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
