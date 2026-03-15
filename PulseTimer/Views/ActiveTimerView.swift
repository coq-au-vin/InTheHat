import SwiftUI

struct ActiveTimerView: View {
    @EnvironmentObject private var workoutManager: WorkoutManager

    private var phaseBackground: Color {
        switch workoutManager.state {
        case .countdown:  return .theme.warning
        case .work:       return .theme.rest      // Seafoam Sage — greenish
        case .rest:       return .theme.work      // Guava Pink   — reddish
        case .roundRest:  return .theme.warning
        case .finished:   return .theme.rest      // Seafoam Sage — celebratory green
        case .idle:       return .theme.background
        }
    }

    // Slot 1 — phase badge
    private var phaseLabel: String {
        switch workoutManager.state {
        case .countdown:  return "GET READY"
        case .work:       return "WORK"
        case .rest:       return "REST"
        case .roundRest:  return "ROUND REST"
        case .finished:   return ""
        case .idle:       return ""
        }
    }

    // Slot 2 — exercise name (nil hides it but reserves space)
    private var exerciseNameLine: String? {
        switch workoutManager.state {
        case .countdown:
            if let name = workoutManager.config.name(for: 1) { return "Up first: \(name)" }
            return nil
        case .work(let exercise, _):
            return workoutManager.config.name(for: exercise)
        case .rest(let exercise, _):
            let next = exercise < workoutManager.config.exercisesPerRound ? exercise + 1 : 1
            if let name = workoutManager.config.name(for: next) { return "Up next: \(name)" }
            return nil
        default:
            return nil
        }
    }

    // The number shown inside the ring — count for countdown, seconds for everything else
    private var displayValue: Int {
        if case .countdown(let count) = workoutManager.state { return count }
        return workoutManager.displaySeconds
    }

    // Slot 4 — SF Mono context line
    private var countLabel: String {
        switch workoutManager.state {
        case .countdown:
            return "Round 1  ·  Exercise 1"
        case .work(let exercise, let round):
            return "Exercise \(exercise)/\(workoutManager.config.exercisesPerRound)  ·  Round \(round)/\(workoutManager.config.rounds)"
        case .rest(let exercise, let round):
            return "Exercise \(exercise)/\(workoutManager.config.exercisesPerRound)  ·  Round \(round)/\(workoutManager.config.rounds)"
        case .roundRest(let completed):
            return "Round \(completed)/\(workoutManager.config.rounds) complete  ·  Round \(completed + 1) next"
        case .finished, .idle:
            return ""
        }
    }

    // Total work time for the Well Done screen
    private var totalWorkSeconds: Int {
        workoutManager.config.workDuration *
        workoutManager.config.exercisesPerRound *
        workoutManager.config.rounds
    }

    private var workTimeFormatted: String {
        let m = totalWorkSeconds / 60
        let s = totalWorkSeconds % 60
        switch (m, s) {
        case (0, _):       return "\(s) seconds"
        case (_, 0):       return "\(m) minutes"
        default:           return "\(m) min \(s) sec"
        }
    }

    var body: some View {
        ZStack {
            phaseBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.45), value: workoutManager.state)

            if workoutManager.state == .finished {
                wellDoneView
            } else {
                activeView
            }
        }
    }

    // MARK: - Active view (countdown + work/rest/roundRest)

    private var activeView: some View {
        VStack(spacing: 0) {
            Spacer()

            // ── Slot 1: Phase badge ───────────────────────────────────────────
            Text(phaseLabel)
                .font(.rounded(.subheadline, weight: .bold))
                .tracking(3)
                .foregroundStyle(Color.theme.textPrimary.opacity(0.55))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.theme.textPrimary.opacity(0.08), in: Capsule())
                .animation(.easeInOut(duration: 0.3), value: phaseLabel)

            Spacer().frame(height: 14)

            // ── Slot 2: Exercise name — fixed 40 pt height ───────────────────
            Text(exerciseNameLine ?? " ")
                .font(.roundedSize(26))
                .foregroundStyle(Color.theme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 32)
                .frame(height: 40)
                .opacity(exerciseNameLine != nil ? 1 : 0)
                .animation(.easeInOut(duration: 0.25), value: exerciseNameLine)

            Spacer().frame(height: 20)

            // ── Slot 3: Timer ring ────────────────────────────────────────────
            ZStack {
                // Hide the ring during countdown — just show the big number
                if case .countdown = workoutManager.state {
                    Circle()
                        .stroke(Color.theme.textPrimary.opacity(0.08), lineWidth: 14)
                        .frame(width: 260, height: 260)
                } else {
                    CircularProgressView(
                        progress: workoutManager.phaseProgress,
                        lineWidth: 14,
                        progressColor: .theme.textPrimary,
                        trackColor: .theme.textPrimary.opacity(0.1)
                    )
                    .frame(width: 260, height: 260)
                }

                TimerDisplayView(seconds: displayValue, color: .theme.textPrimary)
            }

            Spacer().frame(height: 20)

            // ── Slot 4: Count — SF Mono ───────────────────────────────────────
            Text(countLabel)
                .font(.monoStats(.subheadline))
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .animation(.easeInOut(duration: 0.25), value: countLabel)

            Spacer()

            // ── Controls (hidden during countdown) ────────────────────────────
            if case .countdown = workoutManager.state {
                Spacer().frame(height: 77) // match button area height
            } else {
                HStack(spacing: 12) {
                    Button {
                        if workoutManager.isPaused { workoutManager.resume() }
                        else { workoutManager.pause() }
                    } label: {
                        Label(
                            workoutManager.isPaused ? "Resume" : "Pause",
                            systemImage: workoutManager.isPaused ? "play.fill" : "pause.fill"
                        )
                        .font(.rounded(.headline))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.theme.textPrimary.opacity(0.1),
                                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .foregroundStyle(Color.theme.textPrimary)
                    }

                    Button { workoutManager.stopWorkout() } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .font(.rounded(.headline))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.theme.textPrimary.opacity(0.1),
                                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .foregroundStyle(Color.theme.textPrimary)
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer().frame(height: 48)
        }
    }

    // MARK: - Well Done view

    private var wellDoneView: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.theme.textPrimary.opacity(0.7))

            Spacer().frame(height: 24)

            Text("WELL DONE!")
                .font(.roundedSize(42))
                .foregroundStyle(Color.theme.textPrimary)
                .tracking(1)

            Spacer().frame(height: 32)

            Text("You completed")
                .font(.rounded(.title3, weight: .regular))
                .foregroundStyle(Color.theme.textSecondary)

            Spacer().frame(height: 8)

            Text(workTimeFormatted)
                .font(.dinTimer(size: 52))
                .foregroundStyle(Color.theme.textPrimary)

            Spacer().frame(height: 8)

            Text("of exercise")
                .font(.rounded(.title3, weight: .regular))
                .foregroundStyle(Color.theme.textSecondary)

            Spacer()

            Text("Tap anywhere to continue")
                .font(.monoStats(.footnote))
                .foregroundStyle(Color.theme.textSecondary.opacity(0.5))
                .padding(.bottom, 52)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { workoutManager.stopWorkout() }
    }
}

#Preview {
    ActiveTimerView()
        .environmentObject({
            let m = WorkoutManager(audioManager: AudioManager(), notificationManager: NotificationManager())
            return m
        }())
}
