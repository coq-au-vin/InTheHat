import Foundation

struct WorkoutConfiguration: Codable, Equatable {
    var workDuration: Int = 30
    var restDuration: Int = 15
    var exercisesPerRound: Int = 5
    var rounds: Int = 3
    var restBetweenRounds: Int = 60
    /// Optional names for each exercise slot. May be shorter than exercisesPerRound.
    var exerciseNames: [String] = []

    static let `default` = WorkoutConfiguration()

    var totalIntervalCount: Int {
        let intervalsPerRound = exercisesPerRound * 2
        return intervalsPerRound * rounds
    }

    var totalDuration: Int {
        let workPerRound = workDuration * exercisesPerRound
        let restPerRound = restDuration * exercisesPerRound
        let roundWork = (workPerRound + restPerRound) * rounds
        let roundRests = restBetweenRounds * (rounds - 1)
        return roundWork + roundRests
    }

    /// Returns the exercise name for 1-based index, or nil if not set / blank.
    func name(for exercise: Int) -> String? {
        guard exercise >= 1, exercise <= exerciseNames.count else { return nil }
        let n = exerciseNames[exercise - 1].trimmingCharacters(in: .whitespaces)
        return n.isEmpty ? nil : n
    }
}
