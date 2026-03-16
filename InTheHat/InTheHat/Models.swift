import Foundation

// MARK: - Game Settings
struct GameSettings: Codable {
    var numPlayers: Int = 4
    var namesPerPlayer: Int = 3
    var numTeams: Int = 2
    var secondsPerRound: Int = 60
}

// MARK: - Player
struct Player: Codable, Identifiable {
    var id = UUID()
    var name: String
    var enteredNames: [String]
}

// MARK: - Team
struct Team: Codable, Identifiable {
    var id = UUID()
    var name: String
    var colorName: String
    var playerNames: [String]
    var score: Int = 0
    var currentDescriberIndex: Int = 0
}

// MARK: - Name Stats
struct NameStat: Codable {
    var timesPassed: Int = 0
    var totalTimeSpent: TimeInterval = 0   // cumulative screen time across all appearances
    var guessTime: TimeInterval? = nil     // time from LAST appearance to Correct (nil if not guessed)
    var isGuessed: Bool = false
    var guessedByPlayer: String? = nil
}

// MARK: - Player Stats
struct PlayerStat: Codable {
    var totalGuessTime: TimeInterval = 0
    var guessCount: Int = 0
    var averageGuessTime: TimeInterval {
        guessCount > 0 ? totalGuessTime / Double(guessCount) : .infinity
    }
}

// MARK: - Turn
struct Turn: Codable, Identifiable {
    var id = UUID()
    var roundNumber: Int
    var teamName: String
    var teamColorName: String
    var playerName: String
    var namesGuessed: [String]
}

// MARK: - Pass State
/// Tracks whether/how the pass mechanic has been used in a round.
enum PassState: Codable, Equatable {
    case none
    case usedOnce(String)   // Name that was passed; it lives at the end of the hat
    case locked(String)     // Returned to passed name; cannot pass again

    enum CodingKeys: String, CodingKey { case type, value }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .type) {
        case "usedOnce": self = .usedOnce(try c.decode(String.self, forKey: .value))
        case "locked":   self = .locked(try c.decode(String.self, forKey: .value))
        default:         self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none:           try c.encode("none",     forKey: .type)
        case .usedOnce(let v): try c.encode("usedOnce", forKey: .type); try c.encode(v, forKey: .value)
        case .locked(let v):   try c.encode("locked",   forKey: .type); try c.encode(v, forKey: .value)
        }
    }
}

// MARK: - Game Phase
enum GamePhase: Codable, Equatable {
    case setup
    case enteringPlayerName(Int)
    case enteringNames(Int)
    case passingPhone(Int)
    case teamReveal
    case getReady
    case playing
    case roundSummary
    case gameEnd

    enum CodingKeys: String, CodingKey { case type, index }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .type) {
        case "enteringPlayerName": self = .enteringPlayerName(try c.decode(Int.self, forKey: .index))
        case "enteringNames":      self = .enteringNames(try c.decode(Int.self, forKey: .index))
        case "passingPhone":       self = .passingPhone(try c.decode(Int.self, forKey: .index))
        case "teamReveal":         self = .teamReveal
        case "getReady":           self = .getReady
        case "playing":            self = .playing
        case "roundSummary":       self = .roundSummary
        case "gameEnd":            self = .gameEnd
        default:                   self = .setup
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .setup:                   try c.encode("setup",               forKey: .type)
        case .enteringPlayerName(let i): try c.encode("enteringPlayerName", forKey: .type); try c.encode(i, forKey: .index)
        case .enteringNames(let i):     try c.encode("enteringNames",      forKey: .type); try c.encode(i, forKey: .index)
        case .passingPhone(let i):      try c.encode("passingPhone",       forKey: .type); try c.encode(i, forKey: .index)
        case .teamReveal:              try c.encode("teamReveal",          forKey: .type)
        case .getReady:                try c.encode("getReady",            forKey: .type)
        case .playing:                 try c.encode("playing",             forKey: .type)
        case .roundSummary:            try c.encode("roundSummary",        forKey: .type)
        case .gameEnd:                 try c.encode("gameEnd",             forKey: .type)
        }
    }
}
