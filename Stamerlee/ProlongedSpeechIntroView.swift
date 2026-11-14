import SwiftUI

// MARK: - Prolonged Speech Intro View
/// Introduces the Prolonged Speech stretch and smoothing technique with a live chroma-keyed video.
public struct ProlongedSpeechIntroView: View {
    @Bindable public var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
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
                    Text("Let's start with\nProlonged Speech")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryDark)
                        .lineSpacing(2)

                    Text("Learn to gently stretch sounds and connect words smoothly. This technique can help reduce speech tension and improve fluency with practice")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                // Chroma Key Video Hero
                ZStack {
                    ChromaKeyVideoView(videoName: "prolongedvideo")
                        .aspectRatio(720.0 / 1280.0, contentMode: .fit)
                        .frame(maxHeight: 340)
                        .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)

                Spacer()

                // Bottom CTA Button ("Continue")
                VStack {
                    PrimaryActionButton(title: "Continue") {
                        state.hasSeenProlongedSpeechIntro = true
                        state.navigate(to: .prolongedSpeechDifficulty)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
