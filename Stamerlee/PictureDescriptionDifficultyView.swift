import SwiftUI

// MARK: - Picture Description Intro View
/// Introduces the Picture Description fluency and spontaneous expression technique.
public struct PictureDescriptionIntroView: View {
    @Bindable public var state: AppState

    @State private var breatheEffect: Bool = false

    private let heroFallbackPath = "/Users/user89/Documents/stammerlee/Stamerlee/pictures/picturehero.png"

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
                    Text("Let's start with\nPicture Description")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .lineSpacing(2)

                    Text("Picture Description helps you turn what you see into words, organise your thoughts and express ideas more confidently in everyday conversations.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                // Hero Illustration from uploaded screenshot
                ZStack {
                    if let uiImage = StamerleeImageLoader.loadHeroImage(
                        name: "PictureHero",
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
                                Image(systemName: "photo.artframe")
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
                        state.hasSeenPictureDescriptionIntro = true
                        state.navigate(to: .pictureDescriptionDifficulty)
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
                        state.navigate(to: .pictureDescriptionIntro, forward: false)
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
