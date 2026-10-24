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
        Button(action: action) {
            HStack {
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color(red: 80 / 255, green: 75 / 255, blue: 175 / 255))
                        .clipShape(Circle())
                }
                Spacer()
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryLight)
                Spacer()
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right")
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
