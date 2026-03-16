import SwiftUI

// MARK: - Numeric input control (tap box to type, + / − to nudge)

private struct ValueInputRow: View {
    let label: String
    let unit: String
    let range: ClosedRange<Int>
    let step: Int
    @Binding var value: Int

    @State private var text: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.rounded(.body, weight: .regular))
                .foregroundStyle(Color.theme.textPrimary)
            Spacer()
            HStack(spacing: 0) {
                Button { nudge(-step) } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Color.theme.textSecondary)
                }
                TextField("", text: $text)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.monoStats(.body))
                    .foregroundStyle(Color.theme.textPrimary)
                    .frame(width: 46)
                    .focused($focused)
                    .onSubmit { commit() }
                    .onChange(of: focused) { _, isFocused in
                        if !isFocused { commit() }
                    }
                Button { nudge(step) } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }
            .background(Color.theme.background,
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            if !unit.isEmpty {
                Text(unit)
                    .font(.rounded(.footnote, weight: .regular))
                    .foregroundStyle(Color.theme.textSecondary)
                    .frame(width: 22, alignment: .leading)
            }
        }
        .onAppear { text = "\(value)" }
        .onChange(of: value) { _, new in if !focused { text = "\(new)" } }
    }

    private func nudge(_ delta: Int) {
        value = min(max(value + delta, range.lowerBound), range.upperBound)
        text = "\(value)"
    }

    private func commit() {
        if let n = Int(text) { value = min(max(n, range.lowerBound), range.upperBound) }
        text = "\(value)"
    }
}

// MARK: - Themed card section

private struct CardSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section label — SF Mono, Pebble Gray, tracked caps
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.monoStats(.caption))
                    .foregroundStyle(Color.theme.textSecondary)
                Text(title.uppercased())
                    .font(.monoStats(.caption))
                    .tracking(1.4)
                    .foregroundStyle(Color.theme.textSecondary)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 8)

            VStack(spacing: 0) { content }
                .background(Color.theme.surface,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Thin divider inside cards

private struct RowDivider: View {
    var body: some View {
        Divider()
            .overlay(Color.theme.textPrimary.opacity(0.06))
            .padding(.leading, 16)
    }
}

// MARK: - SetupView

struct SetupView: View {
    @EnvironmentObject private var workoutManager: WorkoutManager
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var savedWorkoutsManager: SavedWorkoutsManager

    @State private var exerciseNames: [String] = []
    @State private var showExerciseNames = false
    @State private var showSavedWorkouts = false

    private var config: Binding<WorkoutConfiguration> { $workoutManager.config }

    private var totalTimeFormatted: String {
        let total = workoutManager.config.totalDuration
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header.padding(.bottom, 28)

                    VStack(spacing: 20) {
                        timingCard
                        structureCard
                        exerciseNamesCard
                        summaryAndStart
                    }
                    .padding(.bottom, 40)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarHidden(true)
        .onAppear { resizeNames(to: workoutManager.config.exercisesPerRound) }
    }

    // MARK: Header

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            // Warm tropical gradient: Guava Pink → Mango Pulp
            LinearGradient(
                colors: [Color.theme.work, Color.theme.warning],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 10) {
                    Image(systemName: "bolt.heart.fill")
                        .font(.roundedSize(30))
                        .foregroundStyle(Color.theme.textPrimary.opacity(0.7))
                    Text("PulseTimer")
                        .font(.roundedSize(34))
                        .foregroundStyle(Color.theme.textPrimary)
                }
                Text("Configure your workout")
                    .font(.rounded(.subheadline, weight: .regular))
                    .foregroundStyle(Color.theme.textPrimary.opacity(0.6))
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 28)
        }
        .overlay(alignment: .topTrailing) {
            Button { showSavedWorkouts = true } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.theme.textPrimary.opacity(0.75))
                    .frame(width: 44, height: 44)
            }
            .padding(.top, 52)
            .padding(.trailing, 12)
        }
        .sheet(isPresented: $showSavedWorkouts) {
            SavedWorkoutsSheet(
                currentConfig: workoutManager.config,
                onLoad: { config in
                    workoutManager.config = config
                    resizeNames(to: config.exercisesPerRound)
                    exerciseNames = config.exerciseNames + Array(
                        repeating: "",
                        count: max(0, config.exercisesPerRound - config.exerciseNames.count)
                    )
                }
            )
            .environmentObject(savedWorkoutsManager)
        }
    }

    // MARK: Timing card

    private var timingCard: some View {
        CardSection(title: "Timing", systemImage: "timer") {
            ValueInputRow(label: "Work", unit: "sec",
                          range: 5...300, step: 5,
                          value: config.workDuration)
                .padding(.horizontal, 16).padding(.vertical, 13)
            RowDivider()
            ValueInputRow(label: "Rest", unit: "sec",
                          range: 5...300, step: 5,
                          value: config.restDuration)
                .padding(.horizontal, 16).padding(.vertical, 13)
        }
    }

    // MARK: Structure card

    private var structureCard: some View {
        CardSection(title: "Structure", systemImage: "arrow.trianglehead.2.clockwise") {
            ValueInputRow(label: "Exercises per round", unit: "",
                          range: 1...20, step: 1,
                          value: config.exercisesPerRound)
                .padding(.horizontal, 16).padding(.vertical, 13)
                .onChange(of: workoutManager.config.exercisesPerRound) { _, n in
                    resizeNames(to: n)
                }
            RowDivider()
            ValueInputRow(label: "Rounds", unit: "",
                          range: 1...20, step: 1,
                          value: config.rounds)
                .padding(.horizontal, 16).padding(.vertical, 13)
            RowDivider()
            ValueInputRow(label: "Rest between rounds", unit: "sec",
                          range: 10...300, step: 10,
                          value: config.restBetweenRounds)
                .padding(.horizontal, 16).padding(.vertical, 13)
        }
    }

    // MARK: Exercise names (optional, collapsible)

    private var exerciseNamesCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Toggle header — same style as CardSection label
            Button {
                withAnimation(.spring(duration: 0.3)) { showExerciseNames.toggle() }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "list.bullet")
                        .font(.monoStats(.caption))
                        .foregroundStyle(Color.theme.textSecondary)
                    Text("EXERCISE NAMES")
                        .font(.monoStats(.caption))
                        .tracking(1.4)
                        .foregroundStyle(Color.theme.textSecondary)
                    Text("— optional")
                        .font(.rounded(.caption, weight: .regular))
                        .foregroundStyle(Color.theme.textSecondary.opacity(0.6))
                    Spacer()
                    Image(systemName: showExerciseNames ? "chevron.up" : "chevron.down")
                        .font(.rounded(.caption))
                        .foregroundStyle(Color.theme.textSecondary.opacity(0.5))
                }
                .padding(.horizontal, 6)
                .padding(.bottom, showExerciseNames ? 8 : 0)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            if showExerciseNames {
                VStack(spacing: 0) {
                    ForEach(exerciseNames.indices, id: \.self) { i in
                        HStack {
                            Text("Exercise \(i + 1)")
                                .font(.rounded(.body, weight: .regular))
                                .foregroundStyle(Color.theme.textPrimary)
                            Spacer()
                            TextField("e.g. Squats", text: $exerciseNames[i])
                                .multilineTextAlignment(.trailing)
                                .font(.rounded(.body, weight: .regular))
                                .foregroundStyle(Color.theme.textSecondary)
                                .frame(maxWidth: 160)
                                .onChange(of: exerciseNames[i]) { _, _ in
                                    workoutManager.config.exerciseNames = exerciseNames
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)

                        if i < exerciseNames.indices.last! {
                            RowDivider()
                        }
                    }
                }
                .background(Color.theme.surface,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: Summary + Start

    private var summaryAndStart: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Total workout", systemImage: "clock")
                    .font(.rounded(.subheadline, weight: .regular))
                    .foregroundStyle(Color.theme.textSecondary)
                Spacer()
                Text(totalTimeFormatted)
                    .font(.monoStats(.subheadline))
                    .foregroundStyle(Color.theme.textPrimary)
            }
            .padding(.horizontal, 20)

            Button {
                workoutManager.config.exerciseNames = exerciseNames
                audioManager.startSilentLoop()
                workoutManager.startWorkout()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.rounded())
                    Text("Start Workout")
                        .font(.rounded(.title3))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(
                        colors: [Color.theme.work, Color.theme.warning],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .foregroundStyle(Color.theme.textPrimary)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: Helpers

    private func resizeNames(to count: Int) {
        if exerciseNames.count < count {
            exerciseNames.append(contentsOf: Array(repeating: "", count: count - exerciseNames.count))
        } else if exerciseNames.count > count {
            exerciseNames = Array(exerciseNames.prefix(count))
        }
        workoutManager.config.exerciseNames = exerciseNames
    }
}

// MARK: - Saved Workouts Sheet

private struct SavedWorkoutsSheet: View {
    @EnvironmentObject private var savedWorkoutsManager: SavedWorkoutsManager
    @Environment(\.dismiss) private var dismiss

    let currentConfig: WorkoutConfiguration
    let onLoad: (WorkoutConfiguration) -> Void

    @State private var showSaveAlert = false
    @State private var workoutName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()

                if savedWorkoutsManager.workouts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.theme.textSecondary)
                        Text("No saved workouts yet")
                            .font(.rounded(.body, weight: .regular))
                            .foregroundStyle(Color.theme.textSecondary)
                        Text("Tap 'Save current' to save this workout.")
                            .font(.rounded(.footnote, weight: .regular))
                            .foregroundStyle(Color.theme.textSecondary.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                } else {
                    List {
                        ForEach(savedWorkoutsManager.workouts) { workout in
                            SavedWorkoutRow(workout: workout) {
                                onLoad(workout.config)
                                dismiss()
                            }
                        }
                        .onDelete { savedWorkoutsManager.delete(at: $0) }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.theme.background)
                }
            }
            .navigationTitle("Saved Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.theme.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .font(.rounded(.body, weight: .semibold))
                        .foregroundStyle(Color.theme.textPrimary)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if !savedWorkoutsManager.workouts.isEmpty {
                        EditButton()
                            .font(.rounded(.subheadline, weight: .semibold))
                            .foregroundStyle(Color.theme.textPrimary)
                    }
                    Button {
                        workoutName = ""
                        showSaveAlert = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save current")
                        }
                        .font(.rounded(.subheadline, weight: .semibold))
                        .foregroundStyle(Color.theme.textPrimary)
                    }
                }
            }
        }
        .alert("Save Workout", isPresented: $showSaveAlert) {
            TextField("e.g. Morning HIIT", text: $workoutName)
            Button("Save") {
                let trimmed = workoutName.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    savedWorkoutsManager.save(currentConfig, name: trimmed)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Give this workout a name")
        }
    }
}

private struct SavedWorkoutRow: View {
    let workout: SavedWorkout
    let onLoad: () -> Void

    private var subtitle: String {
        let total = workout.config.totalDuration
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        let time = h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
        return "\(workout.config.exercisesPerRound) exercises · \(workout.config.rounds) rounds · \(time)"
    }

    var body: some View {
        Button(action: onLoad) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(workout.name)
                        .font(.rounded(.body, weight: .semibold))
                        .foregroundStyle(Color.theme.textPrimary)
                    Text(subtitle)
                        .font(.rounded(.footnote, weight: .regular))
                        .foregroundStyle(Color.theme.textSecondary)
                }
                Spacer()
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.theme.textSecondary)
            }
            .padding(.vertical, 6)
        }
        .listRowBackground(Color.theme.surface)
    }
}

#Preview {
    NavigationStack {
        SetupView()
            .environmentObject(WorkoutManager(
                audioManager: AudioManager(),
                notificationManager: NotificationManager()
            ))
            .environmentObject(AudioManager())
            .environmentObject(SavedWorkoutsManager())
    }
}
