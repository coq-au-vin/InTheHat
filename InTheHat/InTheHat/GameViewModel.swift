import Foundation
import Combine
import SwiftUI

class GameViewModel: ObservableObject {

    // MARK: - Published State
    @Published var settings = GameSettings()
    @Published var phase: GamePhase = .setup

    // Players & Teams
    @Published var players: [Player] = []
    @Published var teams: [Team] = []

    // The Hat
    @Published var hat: [String] = []

    // Round state
    @Published var currentTeamIndex: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var currentName: String? = nil
    @Published var passState: PassState = .none
    @Published var guessedThisRound: [String] = []
    @Published var isTimerRunning: Bool = false

    // Transient entry state (not persisted long-term)
    @Published var currentPlayerName: String = ""

    // Describer & stats
    @Published var currentDescriberName: String = ""
    @Published var nameStats: [String: NameStat] = [:]
    @Published var playerStats: [String: PlayerStat] = [:]
    @Published var completedTurns: [Turn] = []
    @Published var roundNumber: Int = 0

    private var nameAppearedAt: Date? = nil
    private var timerCancellable: AnyCancellable?
    private let stateKey = "InTheHat_GameState_v2"

    // MARK: - Setup Phase

    func startSetup() {
        CelebrityDatabase.shared.reset()
        players = []
        teams = []
        hat = []
        guessedThisRound = []
        phase = .enteringPlayerName(0)
        saveState()
    }

    func submitPlayerName(_ name: String, forIndex playerIndex: Int) {
        currentPlayerName = name
        phase = .enteringNames(playerIndex)
        saveState()
    }

    func submitNames(_ names: [String], playerName: String, playerIndex: Int) {
        let filtered = names.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
        let player = Player(name: playerName, enteredNames: filtered)
        players.append(player)
        hat.append(contentsOf: filtered)

        let nextIndex = playerIndex + 1
        if nextIndex < settings.numPlayers {
            phase = .passingPhone(playerIndex)
        } else {
            assignTeams()
            phase = .teamReveal
        }
        saveState()
    }

    func advanceFromPassPhone(playerIndex: Int) {
        phase = .enteringPlayerName(playerIndex + 1)
        saveState()
    }

    // MARK: - Team Assignment

    private func assignTeams() {
        let colors = ["Red", "Blue", "Green", "Yellow", "Purple", "Orange", "Pink", "Teal"]
        let count = min(settings.numTeams, colors.count)
        let shuffled = players.shuffled()

        teams = (0..<count).map { i in
            Team(name: "Team \(colors[i])", colorName: colors[i], playerNames: [])
        }
        for (i, player) in shuffled.enumerated() {
            teams[i % count].playerNames.append(player.name)
        }
        saveState()
    }

    // MARK: - Describer Helpers

    private func setCurrentDescriber() {
        guard !teams.isEmpty, currentTeamIndex < teams.count else { return }
        let team = teams[currentTeamIndex]
        guard !team.playerNames.isEmpty else { return }
        currentDescriberName = team.playerNames[team.currentDescriberIndex]
    }

    private func advanceDescriberForCurrentTeam() {
        guard !teams.isEmpty, currentTeamIndex < teams.count else { return }
        let count = teams[currentTeamIndex].playerNames.count
        guard count > 0 else { return }
        teams[currentTeamIndex].currentDescriberIndex = (teams[currentTeamIndex].currentDescriberIndex + 1) % count
    }

    // MARK: - Game Start

    func startGame() {
        hat.shuffle()
        currentTeamIndex = 0
        roundNumber = 0
        nameStats = [:]
        playerStats = [:]
        completedTurns = []
        setCurrentDescriber()
        phase = .getReady
        saveState()
    }

    func beginRoundFromReady() {
        roundNumber += 1
        beginRound()
    }

    func beginRound() {
        guessedThisRound = []
        passState = .none
        timeRemaining = settings.secondsPerRound

        guard !hat.isEmpty else {
            phase = .gameEnd
            saveState()
            return
        }

        phase = .playing
        currentName = hat.removeFirst()
        nameAppearedAt = Date()
        startTimer()
        saveState()
    }

    // MARK: - Timer

    private func startTimer() {
        isTimerRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    self.endRound()
                }
            }
    }

    private func stopTimer() {
        isTimerRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func resumeTimerIfNeeded() {
        if phase == .playing, !isTimerRunning, currentName != nil {
            nameAppearedAt = Date()
            startTimer()
        }
    }

    // MARK: - Gameplay Actions

    func correct() {
        guard let name = currentName else { return }
        let elapsed = nameAppearedAt.map { Date().timeIntervalSince($0) } ?? 0
        nameAppearedAt = nil

        var stat = nameStats[name] ?? NameStat()
        stat.totalTimeSpent += elapsed
        stat.guessTime = elapsed
        stat.isGuessed = true
        stat.guessedByPlayer = currentDescriberName
        nameStats[name] = stat

        var pStat = playerStats[currentDescriberName] ?? PlayerStat()
        pStat.totalGuessTime += elapsed
        pStat.guessCount += 1
        playerStats[currentDescriberName] = pStat

        guessedThisRound.append(name)
        if currentTeamIndex < teams.count {
            teams[currentTeamIndex].score += 1
        }

        switch passState {
        case .usedOnce(let p) where p == name: passState = .none
        case .locked(let p)   where p == name: passState = .none
        default: break
        }

        if hat.isEmpty {
            currentName = nil
            stopTimer()
            logTurn()
            phase = .roundSummary
            saveState()
            return
        }

        currentName = hat.removeFirst()
        nameAppearedAt = Date()
        saveState()
    }

    func pass() {
        guard let name = currentName else { return }
        let elapsed = nameAppearedAt.map { Date().timeIntervalSince($0) } ?? 0
        nameAppearedAt = nil

        switch passState {
        case .none:
            var stat = nameStats[name] ?? NameStat()
            stat.totalTimeSpent += elapsed
            stat.timesPassed += 1
            nameStats[name] = stat

            hat.append(name)
            passState = .usedOnce(name)

            if hat.count == 1 {
                currentName = hat.removeFirst()
                passState = .locked(currentName!)
            } else {
                currentName = hat.removeFirst()
            }
            nameAppearedAt = Date()

        case .usedOnce(let passedName):
            // Record time for the name we're leaving
            var stat = nameStats[name] ?? NameStat()
            stat.totalTimeSpent += elapsed
            nameStats[name] = stat

            // Put the current name back in hat
            hat.append(name)

            // Pull passedName out of hat and lock on it
            if let idx = hat.firstIndex(of: passedName) {
                hat.remove(at: idx)
            }
            currentName = passedName
            passState = .locked(passedName)
            nameAppearedAt = Date()

        case .locked:
            break
        }
        saveState()
    }

    var canPass: Bool {
        if case .locked = passState { return false }
        return true
    }

    // MARK: - Round End

    func endRound() {
        stopTimer()
        if let name = currentName {
            let elapsed = nameAppearedAt.map { Date().timeIntervalSince($0) } ?? 0
            nameAppearedAt = nil
            var stat = nameStats[name] ?? NameStat()
            stat.totalTimeSpent += elapsed
            nameStats[name] = stat
            hat.append(name)
            currentName = nil
        }
        passState = .none
        logTurn()
        phase = .roundSummary
        saveState()
    }

    private func logTurn() {
        guard !guessedThisRound.isEmpty || true else { return } // always log
        let team = currentTeamIndex < teams.count ? teams[currentTeamIndex] : nil
        let turn = Turn(
            roundNumber: roundNumber,
            teamName: team?.name ?? "",
            teamColorName: team?.colorName ?? "",
            playerName: currentDescriberName,
            namesGuessed: guessedThisRound
        )
        completedTurns.append(turn)
    }

    func nextTurn() {
        advanceDescriberForCurrentTeam()
        currentTeamIndex = (currentTeamIndex + 1) % max(1, teams.count)
        if hat.isEmpty {
            phase = .gameEnd
        } else {
            setCurrentDescriber()
            phase = .getReady
        }
        saveState()
    }

    // MARK: - Sorted Leaderboard

    var sortedTeams: [Team] {
        teams.sorted { $0.score > $1.score }
    }

    // MARK: - Awards

    var speedsterAward: (name: String, time: TimeInterval)? {
        nameStats
            .compactMap { k, v -> (String, TimeInterval)? in
                guard v.isGuessed, let t = v.guessTime else { return nil }
                return (k, t)
            }
            .min(by: { $0.1 < $1.1 })
    }

    var stubbornAward: (name: String, passes: Int)? {
        let guessed = nameStats.filter { $0.value.isGuessed }
        guard !guessed.isEmpty else { return nil }
        guard let entry = guessed.max(by: { $0.value.timesPassed < $1.value.timesPassed }) else { return nil }
        return (entry.key, entry.value.timesPassed)
    }

    var longRoadAward: (name: String, time: TimeInterval)? {
        nameStats
            .filter { $0.value.isGuessed }
            .max(by: { $0.value.totalTimeSpent < $1.value.totalTimeSpent })
            .map { ($0.key, $0.value.totalTimeSpent) }
    }

    var mvpAward: (player: String, avgTime: TimeInterval)? {
        playerStats
            .filter { $0.value.guessCount > 0 }
            .min(by: { $0.value.averageGuessTime < $1.value.averageGuessTime })
            .map { ($0.key, $0.value.averageGuessTime) }
    }

    // MARK: - Reset

    func resetGame() {
        stopTimer()
        settings = GameSettings()
        players = []
        teams = []
        hat = []
        currentName = nil
        passState = .none
        guessedThisRound = []
        currentTeamIndex = 0
        currentDescriberName = ""
        nameStats = [:]
        playerStats = [:]
        completedTurns = []
        roundNumber = 0
        nameAppearedAt = nil
        phase = .setup
        saveState()
    }

    // MARK: - Persistence

    private struct SavedState: Codable {
        var settings: GameSettings
        var phase: GamePhase
        var players: [Player]
        var teams: [Team]
        var hat: [String]
        var currentTeamIndex: Int
        var timeRemaining: Int
        var currentName: String?
        var passState: PassState
        var guessedThisRound: [String]
        var currentPlayerName: String
        var currentDescriberName: String
        var nameStats: [String: NameStat]
        var playerStats: [String: PlayerStat]
        var completedTurns: [Turn]
        var roundNumber: Int
    }

    func saveState() {
        let state = SavedState(
            settings: settings,
            phase: phase,
            players: players,
            teams: teams,
            hat: hat,
            currentTeamIndex: currentTeamIndex,
            timeRemaining: timeRemaining,
            currentName: currentName,
            passState: passState,
            guessedThisRound: guessedThisRound,
            currentPlayerName: currentPlayerName,
            currentDescriberName: currentDescriberName,
            nameStats: nameStats,
            playerStats: playerStats,
            completedTurns: completedTurns,
            roundNumber: roundNumber
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: stateKey)
        }
    }

    func loadState() {
        guard
            let data = UserDefaults.standard.data(forKey: stateKey),
            let state = try? JSONDecoder().decode(SavedState.self, from: data)
        else { return }

        settings = state.settings
        phase = state.phase
        players = state.players
        teams = state.teams
        hat = state.hat
        currentTeamIndex = state.currentTeamIndex
        timeRemaining = state.timeRemaining
        currentName = state.currentName
        passState = state.passState
        guessedThisRound = state.guessedThisRound
        currentPlayerName = state.currentPlayerName
        currentDescriberName = state.currentDescriberName
        nameStats = state.nameStats
        playerStats = state.playerStats
        completedTurns = state.completedTurns
        roundNumber = state.roundNumber
    }
}
