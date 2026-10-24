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
        Button(action: action) {
            HStack {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))
                        .clipShape(Circle())
                }
                Spacer()
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryLight)
                Spacer()
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isCompleted ? StamerleeTheme.primaryBlue : .gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .frame(height: 100)
            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
