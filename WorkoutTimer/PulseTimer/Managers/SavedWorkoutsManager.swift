import Foundation

struct SavedWorkout: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var config: WorkoutConfiguration
    var savedAt: Date = Date()
}

class SavedWorkoutsManager: ObservableObject {
    @Published private(set) var workouts: [SavedWorkout] = []

    private let key = "saved_workouts"

    init() { load() }

    func save(_ config: WorkoutConfiguration, name: String) {
        let workout = SavedWorkout(name: name, config: config)
        workouts.insert(workout, at: 0)
        persist()
    }

    func delete(at offsets: IndexSet) {
        workouts.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SavedWorkout].self, from: data)
        else { return }
        workouts = decoded
    }
}
