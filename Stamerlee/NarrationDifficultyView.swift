import SwiftUI

// MARK: - Narration Difficulty
/// Difficulty selection for Narration, unlocked after one completed Dial Scene.
public struct NarrationDifficultyView: View {
    @Bindable public var state: AppState
    @State private var showLockedAlert = false
    @State private var lockedMessage = ""

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    BackNavButton { state.navigate(to: .homeDashboard, forward: false) }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Text("Narration")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                Text("Practice speaking at your own pace\nthrough guided storytelling.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 34)

                VStack(spacing: 14) {
                    ForEach(["Easy", "Medium", "Hard"], id: \.self) { difficulty in
                        let unlocked = isUnlocked(difficulty)
                        difficultyCard(
                            title: difficulty,
                            isLocked: !unlocked,
                            isCompleted: state.completedNarrationDifficulties.contains(difficulty)
                        ) {
                            guard unlocked else {
                                let prerequisite = difficulty == "Hard" ? "Medium" : "Easy"
                                lockedMessage = "Complete Narration \(prerequisite) to unlock \(difficulty)."
                                showLockedAlert = true
                                return
                            }
                            state.selectedNarrationDifficulty = difficulty
                            state.navigate(to: .narrationPractice)
                        }
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
        .alert("Level Locked", isPresented: $showLockedAlert) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text(lockedMessage)
        }
    }

    private func isUnlocked(_ difficulty: String) -> Bool {
        switch difficulty {
        case "Easy": return state.isNarrationUnlocked
        case "Medium": return state.completedNarrationDifficulties.contains("Easy")
        case "Hard": return state.completedNarrationDifficulties.contains("Medium")
        default: return false
        }
    }

    private func difficultyCard(title: String, isLocked: Bool, isCompleted: Bool, action: @escaping () -> Void) -> some View {
        DifficultyCard(
            title: title,
            isLocked: isLocked,
            isCompleted: isCompleted,
            action: action
        )
    }
}
