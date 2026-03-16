import SwiftUI

struct NamesEntryView: View {
    @EnvironmentObject var vm: GameViewModel
    let playerIndex: Int
    let namesPerPlayer: Int

    @State private var names: [String]
    @State private var suggestedIndices: Set<Int> = []
    @FocusState private var focusedField: Int?

    init(playerIndex: Int, namesPerPlayer: Int) {
        self.playerIndex = playerIndex
        self.namesPerPlayer = namesPerPlayer
        _names = State(initialValue: Array(repeating: "", count: namesPerPlayer))
    }

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    suggestButton
                    nameFieldsCard
                    PrimaryButton(title: "Done — Put in Hat", action: submit, enabled: hasEnoughNames)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear { focusedField = 0 }
    }

    // MARK: - Sub-views

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text(vm.currentPlayerName)
                .font(.roundedSize(30))
                .foregroundStyle(Color.theme.textPrimary)
            Text("Add \(namesPerPlayer) names to the hat")
                .font(.monoStats(.subheadline))
                .foregroundStyle(Color.theme.textSecondary)
        }
        .padding(.top, 48)
    }

    private var suggestButton: some View {
        Button(action: suggestNames) {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.subheadline.bold())
                Text("Suggest Names")
                    .font(.rounded(.subheadline))
            }
            .foregroundStyle(Color.theme.accent)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.theme.accent.opacity(0.10))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.theme.accent.opacity(0.3), lineWidth: 1))
        }
    }

    private var nameFieldsCard: some View {
        VStack(spacing: 0) {
            ForEach(0..<namesPerPlayer, id: \.self) { i in
                NameFieldRow(
                    index: i,
                    total: namesPerPlayer,
                    name: $names[i],
                    isSuggested: suggestedIndices.contains(i),
                    focusedField: $focusedField,
                    onEdit: { suggestedIndices.remove(i) },
                    onSubmitLast: submit
                )
            }
        }
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
    }

    // MARK: - Suggest

    private func suggestNames() {
        let alreadyFilled = Set(names.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty })
        let emptyIndices = (0..<namesPerPlayer).filter {
            names[$0].trimmingCharacters(in: .whitespaces).isEmpty
        }
        guard !emptyIndices.isEmpty else { return }

        var suggestions = CelebrityDatabase.shared.getRandomNames(
            count: emptyIndices.count,
            excluding: alreadyFilled
        )

        withAnimation {
            for idx in emptyIndices {
                guard !suggestions.isEmpty else { break }
                names[idx] = suggestions.removeFirst()
                suggestedIndices.insert(idx)
            }
        }
    }

    // MARK: - Submit

    private var hasEnoughNames: Bool {
        names.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private func submit() {
        guard hasEnoughNames else { return }
        vm.submitNames(names, playerName: vm.currentPlayerName, playerIndex: playerIndex)
    }
}

// MARK: - Name field row (extracted to reduce type-checker load)

private struct NameFieldRow: View {
    let index: Int
    let total: Int
    @Binding var name: String
    let isSuggested: Bool
    var focusedField: FocusState<Int?>.Binding
    let onEdit: () -> Void
    let onSubmitLast: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("\(index + 1)")
                    .font(.monoStats(.subheadline))
                    .foregroundStyle(Color.theme.textSecondary)
                    .frame(width: 20, alignment: .trailing)

                TextField("Name \(index + 1)", text: $name)
                    .font(.rounded(.body, weight: .regular))
                    .foregroundStyle(Color.theme.textPrimary)
                    .focused(focusedField, equals: index)
                    .onChange(of: name) { _, _ in onEdit() }
                    .onSubmit {
                        if index < total - 1 {
                            focusedField.wrappedValue = index + 1
                        } else {
                            onSubmitLast()
                        }
                    }

                if isSuggested {
                    Image(systemName: "wand.and.stars")
                        .font(.caption)
                        .foregroundStyle(Color.theme.accent.opacity(0.6))
                        .transition(.opacity)
                }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .background(isSuggested ? Color.theme.accent.opacity(0.06) : Color.clear)
            .animation(.easeInOut(duration: 0.2), value: isSuggested)

            if index < total - 1 {
                Divider().padding(.leading, 48)
            }
        }
    }
}
