import SwiftUI

struct ActiveTimerView: View {
    @EnvironmentObject private var workoutManager: WorkoutManager

    private var phaseBackground: Color {
        switch workoutManager.state {
        case .work:       return .theme.rest      // Seafoam Sage — greenish
        case .rest:       return .theme.work      // Guava Pink   — reddish
        case .roundRest:  return .theme.warning
        case .finished:   return .theme.surface
        case .idle:       return .theme.background
        }
    }

    // Slot 1 — always the same fixed position
    private var phaseLabel: String {
        switch workoutManager.state {
        case .work:       return "WORK"
        case .rest:       return "REST"
        case .roundRest:  return "ROUND REST"
        case .finished:   return "DONE"
        case .idle:       return ""
        }
    }

    // Slot 2 — exercise name, always reserves height, fades in/out
    private var exerciseNameLine: String? {
        switch workoutManager.state {
        case .work(let exercise, _):
            return workoutManager.config.name(for: exercise)
        case .rest(let exercise, _):
            let next = exercise < workoutManager.config.exercisesPerRound ? exercise + 1 : 1
            if let name = workoutManager.config.name(for: next) {
                return "Up next: \(name)"
            }
            return nil
        default:
            return nil
        }
    }

    // Slot 4 — SF Mono technical context
    private var countLabel: String {
        switch workoutManager.state {
        case .work(let exercise, let round):
            return "Exercise \(exercise)/\(workoutManager.config.exercisesPerRound)  ·  Round \(round)/\(workoutManager.config.rounds)"
        case .rest(let exercise, let round):
            return "Exercise \(exercise)/\(workoutManager.config.exercisesPerRound)  ·  Round \(round)/\(workoutManager.config.rounds)"
        case .roundRest(let completed):
            return "Round \(completed)/\(workoutManager.config.rounds) complete  ·  Round \(completed + 1) next"
        case .finished:
            return "All \(workoutManager.config.rounds) rounds complete"
        case .idle:
            return ""
        }
    }

    var body: some View {
        ZStack {
            phaseBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.45), value: workoutManager.state)

            if workoutManager.state == .finished {
                finishedView
            } else {
                activeView
            }
        }
    }

    // MARK: - Active view

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
                .background(Color.theme.textPrimary.opacity(0.08),
                            in: Capsule())
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
                CircularProgressView(
                    progress: workoutManager.phaseProgress,
                    lineWidth: 14,
                    progressColor: .theme.textPrimary,
                    trackColor: .theme.textPrimary.opacity(0.1)
                )
                .frame(width: 260, height: 260)

                TimerDisplayView(
                    seconds: workoutManager.displaySeconds,
                    color: .theme.textPrimary
                )
            }

            Spacer().frame(height: 20)

            // ── Slot 4: Technical count — SF Mono ────────────────────────────
            Text(countLabel)
                .font(.monoStats(.subheadline))
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .animation(.easeInOut(duration: 0.25), value: countLabel)

            Spacer()

            // ── Controls ──────────────────────────────────────────────────────
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
            .padding(.bottom, 48)
        }
    }

    // MARK: - Finished view

    private var finishedView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 90))
                .foregroundStyle(Color.theme.rest)

            Text("Workout Complete!")
                .font(.roundedSize(32))
                .foregroundStyle(Color.theme.textPrimary)
                .multilineTextAlignment(.center)

            Text(countLabel)
                .font(.monoStats())
                .foregroundStyle(Color.theme.textSecondary)

            Spacer()

            Button { workoutManager.stopWorkout() } label: {
                Text("Done")
                    .font(.rounded(.title3))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.theme.rest,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .foregroundStyle(Color.theme.textPrimary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

#Preview {
    ActiveTimerView()
        .environmentObject({
            let m = WorkoutManager(audioManager: AudioManager(), notificationManager: NotificationManager())
            return m
        }())
}
