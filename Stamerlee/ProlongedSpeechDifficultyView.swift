import SwiftUI

// MARK: - Prolonged Speech Difficulty View (Screenshot 4: "pro speech screen")
/// Difficulty selection screen for the Easy, Medium, and Hard exercises.
public struct ProlongedSpeechDifficultyView: View {
    @Bindable public var state: AppState
    
    @State private var showLockedAlert: Bool = false
    @State private var lockedAlertText: String = ""
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()

            BackgroundImagesDecorationView()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Navigation Bar
                HStack {
                    BackNavButton {
                        state.navigate(to: .homeDashboard, forward: false)
                    }
                    Spacer()
                    GlassCloseButton {
                        state.navigate(to: .homeDashboard, forward: false)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Headings
                VStack(alignment: .leading, spacing: 10) {
                    Text("Prolonged Speech")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    
                    Text("Practice stretching sounds for smoother,more fluent speech.")
                        .font(.system(size: 14.5, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 36)
                
                // Difficulty Level Cards
                VStack(spacing: 16) {
                    ForEach(["Words", "Sentences", "Paragraphs"], id: \.self) { difficulty in
                        let locked = isLevelLocked(difficulty)
                        difficultyCard(
                            title: difficulty,
                            isLocked: locked,
                            isCompleted: state.completedProlongedDifficulties.contains(difficulty)
                        ) {
                            if locked {
                                triggerLockedAlert(difficulty: difficulty)
                            } else {
                                state.selectedDifficulty = difficulty
                                state.navigate(to: .prolongedPractice)
                            }
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
            Text(lockedAlertText)
        }
    }
    
    // MARK: - Level Locking Logic
    private func isLevelLocked(_ difficulty: String) -> Bool {
        switch difficulty {
        case "Words":
            return false
        case "Sentences":
            return !state.completedProlongedDifficulties.contains("Words")
        case "Paragraphs":
            return !state.completedProlongedDifficulties.contains("Sentences")
        default:
            return false
        }
    }

    private func triggerLockedAlert(difficulty: String) {
        switch difficulty {
        case "Sentences":
            lockedAlertText = "Complete the Words level to unlock Sentences!"
        case "Paragraphs":
            lockedAlertText = "Complete the Sentences level to unlock Paragraphs!"
        default:
            lockedAlertText = "Complete the previous level to unlock this practice!"
        }
        showLockedAlert = true
    }

    // MARK: - Difficulty Card
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
