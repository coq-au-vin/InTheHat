import SwiftUI

// MARK: - Shared theme (mirrors WorkoutTimer/PulseTimer design system)

extension Color {
    static let theme = Theme.colors
}

enum Theme {
    struct Colors {
        let background    = Color(hex: "F9F7F2")  // Coconut Milk   — main app background
        let surface       = Color(hex: "F0EDE4")  // Sand Dollar    — cards / grouped elements
        let work          = Color(hex: "E69F9B")  // Guava Pink     — warm accent
        let rest          = Color(hex: "A8D0BC")  // Seafoam Sage   — success / positive
        let warning       = Color(hex: "F4D793")  // Mango Pulp     — alerts / highlights
        let textPrimary   = Color(hex: "4A3F35")  // Roasted Coffee — headings & labels
        let textSecondary = Color(hex: "8C8279")  // Pebble Gray    — subtitles & stats
        let accent        = Color(hex: "5B67E8")  // Indigo Blue    — InTheHat primary
        let accentLight   = Color(hex: "8B92F0")  // Periwinkle     — InTheHat gradient end
    }

    static let colors = Colors()
}

// MARK: - Typography

extension Font {
    /// DIN Alternate Bold — large countdown/timer digits
    static func dinTimer(size: CGFloat = 96) -> Font {
        .custom("DINAlternate-Bold", size: size).monospacedDigit()
    }
    /// System Rounded — headings and buttons
    static func rounded(_ style: TextStyle = .body, weight: Weight = .semibold) -> Font {
        .system(style, design: .rounded).weight(weight)
    }
    /// System Rounded at an explicit point size
    static func roundedSize(_ size: CGFloat, weight: Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    /// SF Mono — small technical stats
    static func monoStats(_ style: TextStyle = .caption) -> Font {
        .system(style, design: .monospaced)
    }
}

// MARK: - Hex colour initialiser

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red:     Double(r) / 255,
                  green:   Double(g) / 255,
                  blue:    Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Team colours (game-specific)

extension Color {
    static func teamColor(_ name: String) -> Color {
        switch name {
        case "Red":    return Color(hex: "C0392B")
        case "Blue":   return Color(hex: "2980B9")
        case "Green":  return Color(hex: "27AE60")
        case "Yellow": return Color(hex: "D4A017")
        case "Purple": return Color(hex: "8E44AD")
        case "Orange": return Color(hex: "E67E22")
        case "Pink":   return Color(hex: "E91E8C")
        case "Teal":   return Color(hex: "16A085")
        default:       return Color.theme.textSecondary
        }
    }
}
