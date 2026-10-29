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
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Navigation Bar
                HStack {
                    BackNavButton {
                        state.navigate(to: .homeDashboard, forward: false)
                    }
                    Spacer()
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
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 36)
                
                // Difficulty Level Cards
                VStack(spacing: 16) {
                    ForEach(["Words", "Sentences", "Paragraphs"], id: \.self) { difficulty in
                        difficultyCard(
                            title: difficulty,
                            isLocked: false,
                            isCompleted: state.completedProlongedDifficulties.contains(difficulty)
                        ) {
                            state.selectedDifficulty = difficulty
                            state.navigate(to: .prolongedPractice)
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
