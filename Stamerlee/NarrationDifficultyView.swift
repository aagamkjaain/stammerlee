import SwiftUI

// MARK: - Narration Intro View
/// Introduces the Narration with Mirror practice technique.
public struct NarrationIntroView: View {
    @Bindable public var state: AppState

    @State private var breatheEffect: Bool = false

    private let heroFallbackPath = "/Users/user89/Documents/stammerlee/Stamerlee/pictures/narrationhero.png"

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

                // Headings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Let's start with\nNarration with Mirror")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .lineSpacing(2)

                    Text("Look at yourself in the mirror and narrate your thoughts aloud to practice self-expression, become more comfortable speaking and build confidence.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                // Hero Illustration from uploaded screenshot
                ZStack {
                    if let uiImage = StamerleeImageLoader.loadHeroImage(
                        name: "NarrationHero",
                        fallbackPath: heroFallbackPath
                    ) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 360)
                            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
                            .scaleEffect(breatheEffect ? 1.015 : 0.985)
                            .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: breatheEffect)
                    } else {
                        // Fallback
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 25 / 255, green: 30 / 255, blue: 65 / 255))
                            .frame(width: 250, height: 230)
                            .overlay(
                                Image(systemName: "person.crop.artframe")
                                    .font(.system(size: 60))
                                    .foregroundColor(StamerleeTheme.primaryBlue)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)

                Spacer()

                // Bottom CTA Button ("Continue")
                VStack {
                    PrimaryActionButton(title: "Continue") {
                        state.hasSeenNarrationIntro = true
                        state.navigate(to: .narrationDifficulty)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            breatheEffect = true
        }
    }
}

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
                    BackNavButton { state.navigate(to: .narrationIntro, forward: false) }
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
