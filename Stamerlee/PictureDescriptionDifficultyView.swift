import SwiftUI

// MARK: - Picture Description Difficulty
/// Difficulty selection unlocked after the complete Prolonged Speech sequence.
public struct PictureDescriptionDifficultyView: View {
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
                    BackNavButton {
                        state.navigate(to: .homeDashboard, forward: false)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Text("Picture Description")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                Text("Describe simple pictures using words and\nshort sentences.")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 34)

                VStack(spacing: 14) {
                    ForEach(["Easy", "Medium", "Hard"], id: \.self) { difficulty in
                        let unlocked = state.isPictureDescriptionDifficultyUnlocked(difficulty)
                        difficultyCard(
                            title: difficulty,
                            isLocked: !unlocked,
                            isCompleted: state.completedPictureDescriptionDifficulties.contains(difficulty)
                        ) {
                            guard unlocked else {
                                let prerequisite = difficulty == "Medium" ? "Easy" : "Medium"
                                lockedMessage = "Complete Picture Description \(prerequisite) to unlock \(difficulty)."
                                showLockedAlert = true
                                return
                            }
                            state.selectedPictureDescriptionDifficulty = difficulty
                            state.navigate(to: .pictureDescriptionPractice)
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

    private func difficultyCard(
        title: String,
        isLocked: Bool,
        isCompleted: Bool,
        action: @escaping () -> Void
    ) -> some View {
        DifficultyCard(
            title: title,
            isLocked: isLocked,
            isCompleted: isCompleted,
            action: action
        )
    }
}
