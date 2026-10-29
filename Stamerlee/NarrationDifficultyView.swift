import SwiftUI

// MARK: - Narration Intro View
/// Introduces the Narration with Mirror practice technique.
public struct NarrationIntroView: View {
    @Bindable public var state: AppState

    private let heroFallbackPath = "/Users/user89/Documents/stammerlee/Stamerlee/pictures/narrationhero.png"

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ExerciseIntroSkeletonView(
            title: "Let's start with\nNarration with Mirror",
            subtitle: "Look at yourself in the mirror and narrate your thoughts aloud to practice self-expression, become more comfortable speaking and build confidence.",
            heroImageName: "NarrationHero",
            heroFallbackPath: heroFallbackPath,
            systemIconFallback: "person.crop.artframe",
            onBack: {
                state.navigate(to: .homeDashboard, forward: false)
            },
            onContinue: {
                state.hasSeenNarrationIntro = true
                state.navigate(to: .narrationPractice)
            }
        )
    }
}
