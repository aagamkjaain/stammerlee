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
                        state.navigate(to: .prolongedSpeechIntro, forward: false)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Headings
                VStack(alignment: .leading, spacing: 10) {
                    Text("Prolonged Speech")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                    
                    Text("Practice stretching sounds for smoother,more fluent speech.")
                        .font(.system(size: 14.5, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 36)
                
                // Difficulty Level Cards
                VStack(spacing: 16) {
                    ForEach(["Easy", "Medium", "Hard"], id: \.self) { difficulty in
                        let isUnlocked = state.isProlongedDifficultyUnlocked(difficulty)
                        difficultyCard(
                            title: difficulty,
                            isLocked: !isUnlocked,
                            isCompleted: state.completedProlongedDifficulties.contains(difficulty)
                        ) {
                            guard isUnlocked else {
                                let prerequisite = difficulty == "Hard" ? "Medium" : "Easy"
                                lockedAlertText = "Complete \(prerequisite) practice to unlock \(difficulty)."
                                showLockedAlert = true
                                return
                            }

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
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: isLocked ? .light : .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack {
                if isLocked {
                    // Blue Lock Badge
                    ZStack {
                        Circle()
                            .fill(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                    
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryLight)
                    
                    Spacer()
                } else {
                    Spacer()
                    
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryLight)
                    
                    Spacer()
                }
                
                // Trailing status indicator
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: isCompleted ? 18 : 14, weight: .semibold))
                    .foregroundColor(isCompleted ? StamerleeTheme.primaryBlue : Color.gray.opacity(0.5))
                    .padding(.trailing, 8)
            }
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}
