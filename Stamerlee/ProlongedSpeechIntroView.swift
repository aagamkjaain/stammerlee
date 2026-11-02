import SwiftUI

// MARK: - Prolonged Speech Intro View (Screenshot 3: "prolonged speech")
/// Introduces the Prolonged Speech stretch and smoothing technique.
public struct ProlongedSpeechIntroView: View {
    @Bindable public var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ExerciseIntroSkeletonView(
            title: "Let's start with\nProlonged Speech",
            subtitle: "Learn to gently stretch sounds and connect words smoothly. This technique can help reduce speech tension and improve fluency with practice",
            heroImageName: "ProlongedSpeechHero",
            onBack: {
                state.navigate(to: .homeDashboard, forward: false)
            },
            onContinue: {
                state.hasSeenProlongedSpeechIntro = true
                state.navigate(to: .prolongedSpeechDifficulty)
            }
        )
    }
}
