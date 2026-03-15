import Foundation
import UIKit

enum TimerState: Equatable {
    case idle
    case countdown(count: Int)
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
        switch state {
        case .idle, .finished: return false
        default: return true
        }
    }

    private let audioManager: AudioManager
    private let notificationManager: NotificationManager

    private var timer: Timer?
    private var phaseStartTime: CFAbsoluteTime = 0
    private var accumulatedPauseTime: CFAbsoluteTime = 0
    private var pauseStartTime: CFAbsoluteTime = 0
    private var phaseDuration: CFAbsoluteTime = 0
    private var lastCountdownBuzz: Int = 0

    init(audioManager: AudioManager, notificationManager: NotificationManager) {
        self.audioManager = audioManager
        self.notificationManager = notificationManager
    }

    // MARK: - Public Controls

    func startWorkout() {
        // Offset notifications by 3.5 s to account for the 3-count countdown
        let startTime = Date().addingTimeInterval(3.5)
        notificationManager.scheduleAllNotifications(for: config, startTime: startTime)
        beginPhase(.countdown(count: 3))
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
        lastCountdownBuzz = 0

        if case .countdown(let count) = newState {
            // Countdown: no hold at start — pip fires immediately, snappy feel
            phaseStartTime = CFAbsoluteTimeGetCurrent()
            displaySeconds = count
            audioManager.playPip()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            // Work/rest phases: 0.5 s hold at start before counting down
            phaseStartTime = CFAbsoluteTimeGetCurrent() + 0.5
            displaySeconds = Int(phaseDuration)
        }

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
        let elapsed = max(0, CFAbsoluteTimeGetCurrent() - phaseStartTime - accumulatedPauseTime)
        let remaining = max(0, phaseDuration - elapsed)

        if case .countdown(let count) = state {
            // Show the fixed count number, not a decrementing timer
            displaySeconds = count
            phaseProgress = min(1.0, elapsed / phaseDuration)
        } else {
            displaySeconds = Int(ceil(remaining))
            phaseProgress = min(1.0, elapsed / phaseDuration)

            // Light pip + haptic on 3, 2, 1 during work/rest phases
            if displaySeconds <= 3 && displaySeconds > 0 && displaySeconds != lastCountdownBuzz {
                lastCountdownBuzz = displaySeconds
                audioManager.playPip()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }

        if remaining <= 0 {
            timer?.invalidate()
            timer = nil
            phaseProgress = 1.0

            if case .countdown = state {
                displaySeconds = 0
                // Short gap between countdown pips; bing fires when work begins
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                    self?.advancePhase()
                }
            } else {
                displaySeconds = 0
                triggerTransitionFeedback()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.advancePhase()
                }
            }
        }
    }

    private func advancePhase() {
        let nextState = nextPhase(from: state)

        // Play bing when transitioning INTO the first work phase (the "GO!" signal)
        // and for all subsequent work/rest/roundRest transitions
        if case .countdown(let count) = state, count > 1 {
            // countdown→countdown: pip already fired at beginPhase, nothing here
        } else if case .countdown = state {
            // countdown(1) → work: bing is the GO signal
            triggerTransitionFeedback()
        }
        // work/rest/roundRest transitions: bing already fired in tick() above

        if nextState == .finished {
            state = .finished
            audioManager.stopSilentLoop()
        } else {
            beginPhase(nextState)
        }
    }

    private func nextPhase(from current: TimerState) -> TimerState {
        switch current {
        case .countdown(let count):
            return count > 1 ? .countdown(count: count - 1) : .work(exercise: 1, round: 1)

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
        case .countdown:    return 1
        case .work:         return config.workDuration
        case .rest:         return config.restDuration
        case .roundRest:    return config.restBetweenRounds
        case .idle, .finished: return 0
        }
    }

    private func triggerTransitionFeedback() {
        audioManager.playBing()
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
