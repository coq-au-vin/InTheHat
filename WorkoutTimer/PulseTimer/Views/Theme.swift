import SwiftUI

// MARK: - Color palette

extension Color {
    static let theme = Theme.colors
}

enum Theme {
    struct Colors {
        let background    = Color(hex: "F9F7F2")  // Coconut Milk   — main app background
        let surface       = Color(hex: "F0EDE4")  // Sand Dollar    — cards / grouped elements
        let work          = Color(hex: "E69F9B")  // Guava Pink     — work interval
        let rest          = Color(hex: "A8D0BC")  // Seafoam Sage   — rest / success
        let warning       = Color(hex: "F4D793")  // Mango Pulp     — round rest / alerts
        let textPrimary   = Color(hex: "4A3F35")  // Roasted Coffee — headings & labels
        let textSecondary = Color(hex: "8C8279")  // Pebble Gray    — subtitles & stats
    }

    static let colors = Colors()
}

// MARK: - Typography

extension Font {
    /// DIN Alternate Bold — timer digits. monospacedDigit prevents width flicker.
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
    /// SF Mono — small technical stats (exercise/round counts)
    static func monoStats(_ style: TextStyle = .caption) -> Font {
        .system(style, design: .monospaced)
    }
}

// MARK: - Hex color initialiser

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
