import SwiftUI

// MARK: - Bucket Hat Shape (front view)
//
//  Anatomy (normalised 0→1 coordinates, rect = bounding box of the shape):
//
//       ╭───────────────╮    ← crown dome, peaks at y≈0.08
//      ╱                 ╲
//  ───╱─────────────────── ╲───  ← band (y≈0.60–0.68)
//  ╲                           ╱
//   ╰─────────────────────────╯  ← brim bottom droops to y≈0.95

private struct BucketHatCrownShape: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        var p = Path()
        // Left crown base
        p.move(to: CGPoint(x: w * 0.16, y: h * 0.60))
        // Dome arch
        p.addCurve(
            to:       CGPoint(x: w * 0.84, y: h * 0.60),
            control1: CGPoint(x: w * 0.16, y: h * 0.06),
            control2: CGPoint(x: w * 0.84, y: h * 0.06)
        )
        // Right side down to band bottom
        p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.68))
        // Band bottom across (slight inward curve for depth)
        p.addCurve(
            to:       CGPoint(x: w * 0.16, y: h * 0.68),
            control1: CGPoint(x: w * 0.65, y: h * 0.64),
            control2: CGPoint(x: w * 0.35, y: h * 0.64)
        )
        p.closeSubpath()
        return p
    }
}

private struct BucketHatBrimShape: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        var p = Path()
        // Brim top-left (where it meets the band)
        p.move(to: CGPoint(x: w * 0.02, y: h * 0.68))
        // Brim top — straight across
        p.addLine(to: CGPoint(x: w * 0.98, y: h * 0.68))
        // Brim outer right edge (droops down at the sides)
        p.addQuadCurve(
            to:      CGPoint(x: w * 0.96, y: h * 0.86),
            control: CGPoint(x: w * 1.00, y: h * 0.72)
        )
        // Brim underside — droops lower in the middle
        p.addCurve(
            to:       CGPoint(x: w * 0.04, y: h * 0.86),
            control1: CGPoint(x: w * 0.72, y: h * 0.96),
            control2: CGPoint(x: w * 0.28, y: h * 0.96)
        )
        // Brim outer left edge
        p.addQuadCurve(
            to:      CGPoint(x: w * 0.02, y: h * 0.68),
            control: CGPoint(x: w * 0.00, y: h * 0.72)
        )
        p.closeSubpath()
        return p
    }
}

// MARK: - Hat Icon View

/// A front-facing bucket hat icon. Drop-in for `BaseballCapView` callers.
/// The `size` parameter sets the width; height is `size`.
struct BaseballCapView: View {
    var size: CGFloat = 48
    var color: Color = Color.theme.accent

    var body: some View {
        ZStack {
            // Brim (behind crown)
            BucketHatBrimShape()
                .fill(color.opacity(0.85))
            // Brim outline
            BucketHatBrimShape()
                .stroke(color, lineWidth: max(1, size * 0.028))

            // Crown body
            BucketHatCrownShape()
                .fill(color)
            // Crown outline
            BucketHatCrownShape()
                .stroke(color.opacity(0.6), lineWidth: max(1, size * 0.028))

            // Hat band highlight — thin stripe at the top of the brim
            hatBandLine

            // Small logo circle on crown front
            Circle()
                .fill(color.opacity(0.35))
                .frame(width: max(3, size * 0.09), height: max(3, size * 0.09))
                .offset(y: -size * 0.12)
        }
        .frame(width: size, height: size)
    }

    private var hatBandLine: some View {
        Path { p in
            let w = size, h = size
            p.move(to: CGPoint(x: w * 0.02, y: h * 0.68))
            p.addLine(to: CGPoint(x: w * 0.98, y: h * 0.68))
        }
        .stroke(color.opacity(0.40), lineWidth: max(1, size * 0.022))
    }
}

// MARK: - App Icon View

/// Export at 1024×1024 via ImageRenderer (Simulator) to generate the .png asset.
struct AppIconView: View {
    var iconSize: CGFloat = 120

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1E1B4B"), Color(hex: "3730A3")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            BaseballCapView(size: iconSize * 0.68, color: .white)
        }
        .frame(width: iconSize, height: iconSize)
        .clipShape(RoundedRectangle(cornerRadius: iconSize * 0.224, style: .continuous))
    }
}

// MARK: - Preview

#Preview("Bucket hat sizes") {
    VStack(spacing: 24) {
        AppIconView(iconSize: 180)

        HStack(spacing: 20) {
            BaseballCapView(size: 80, color: Color.theme.accent)
            BaseballCapView(size: 48, color: Color.theme.work)
            BaseballCapView(size: 32, color: Color.theme.rest)
            BaseballCapView(size: 24, color: Color.theme.textPrimary)
        }
    }
    .padding(32)
    .background(Color.theme.background)
}
