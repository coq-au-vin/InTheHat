import SwiftUI
import Photos

struct SetupView: View {
    @EnvironmentObject var vm: GameViewModel
    @State private var iconExported = false

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        BaseballCapView(size: 72, color: Color.theme.accent)
                            .padding(.top, 56)
                            #if DEBUG
                            .onLongPressGesture { exportAppIcon() }
                            #endif
                        Text("In The Hat")
                            .font(.roundedSize(34))
                            .foregroundStyle(Color.theme.textPrimary)
                        Text("Set up your game")
                            .font(.rounded(.subheadline, weight: .regular))
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                    .padding(.bottom, 8)

                    CardSection(title: "PLAYERS") {
                        StepperRow(label: "Number of players",  value: $vm.settings.numPlayers,     range: 2...20)
                        Divider().foregroundStyle(Color.theme.textPrimary.opacity(0.06))
                        StepperRow(label: "Names per player",   value: $vm.settings.namesPerPlayer,  range: 1...10)
                    }

                    CardSection(title: "TEAMS") {
                        StepperRow(label: "Number of teams",    value: $vm.settings.numTeams,        range: 2...8)
                    }

                    CardSection(title: "ROUND") {
                        StepperRow(label: "Seconds per round",  value: $vm.settings.secondsPerRound, range: 10...300, step: 10)
                    }

                    PrimaryButton(title: "Start Setup", action: vm.startSetup)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }

    #if DEBUG
    @MainActor
    private func exportAppIcon() {
        let renderer = ImageRenderer(content: AppIconView(iconSize: 1024))
        renderer.scale = 1.0
        guard let uiImage = renderer.uiImage else { return }
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else { return }
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
            } completionHandler: { success, _ in
                DispatchQueue.main.async { iconExported = success }
            }
        }
    }
    #endif
}

// MARK: - Shared primary button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var enabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.rounded(.title3))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    enabled
                    ? LinearGradient(colors: [Color.theme.accent, Color.theme.accentLight],
                                     startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [Color.theme.surface, Color.theme.surface],
                                     startPoint: .leading, endPoint: .trailing)
                )
                .foregroundStyle(enabled ? .white : Color.theme.textSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .disabled(!enabled)
    }
}

// MARK: - Reusable card section

struct CardSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.monoStats(.caption))
                .tracking(1.4)
                .foregroundStyle(Color.theme.textSecondary)
                .padding(.bottom, 8)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                content
            }
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

// MARK: - Stepper row

struct StepperRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var step: Int = 1

    var body: some View {
        HStack {
            Text(label)
                .font(.rounded(.body, weight: .regular))
                .foregroundStyle(Color.theme.textPrimary)
            Spacer()
            HStack(spacing: 12) {
                Button {
                    if value - step >= range.lowerBound { value -= step }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .background(Color.theme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundStyle(Color.theme.textPrimary)
                }
                Text("\(value)")
                    .font(.rounded(.body))
                    .foregroundStyle(Color.theme.textPrimary)
                    .frame(width: 46, alignment: .center)
                Button {
                    if value + step <= range.upperBound { value += step }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .background(Color.theme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .foregroundStyle(Color.theme.textPrimary)
                }
            }
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 16)
    }
}
