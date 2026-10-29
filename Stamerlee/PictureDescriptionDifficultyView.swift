import SwiftUI

// MARK: - Picture Description Intro View
/// Introduces the Picture Description fluency and spontaneous expression technique.
public struct PictureDescriptionIntroView: View {
    @Bindable public var state: AppState

    private let heroFallbackPath = "/Users/user89/Documents/stammerlee/Stamerlee/pictures/picturehero.png"

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ExerciseIntroSkeletonView(
            title: "Let's start with\nPicture Description",
            subtitle: "Picture Description helps you turn what you see into words, organise your thoughts and express ideas more confidently in everyday conversations.",
            heroImageName: "PictureHero",
            heroFallbackPath: heroFallbackPath,
            systemIconFallback: "photo.artframe",
            onBack: {
                state.navigate(to: .homeDashboard, forward: false)
            },
            onContinue: {
                state.hasSeenPictureDescriptionIntro = true
                state.navigate(to: .pictureDescriptionPractice)
            }
        )
    }
}
