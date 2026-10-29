import SwiftUI

// MARK: - Picture Description Practice
/// Picture-description practice for the selected difficulty.
public struct PictureDescriptionEasyView: View {
    @Bindable public var state: AppState
    @State private var isAnalysisVisible = false
    @State private var selectedWords: Set<String> = ["Sitting", "Smiling"]

    private var difficulty: String {
        state.selectedPictureDescriptionDifficulty
    }

    private var pictureAssetName: String {
        switch difficulty {
        case "Medium":
            return "PictureDescriptionMedium"
        case "Hard":
            return "PictureDescriptionHard"
        default:
            return "PictureDescriptionEasy"
        }
    }

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()

            if isAnalysisVisible {
                analysisView
            } else {
                practiceView
            }
        }
    }

    private var practiceView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                BackNavButton {
                    state.navigate(to: .homeDashboard, forward: false)
                }
                Spacer()
                Text("DAF")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(StamerleeTheme.primaryBlueDark)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Text(difficulty)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 20)

            Text(description)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(StamerleeTheme.textSecondaryDark)
                .padding(.horizontal, 24)
                .padding(.top, 10)

            Spacer(minLength: 16)

            pictureAsset
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)

            Spacer(minLength: 16)

            Button {
                completeCurrentDifficulty()
                withAnimation(.easeInOut(duration: 0.25)) {
                    isAnalysisVisible = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(red: 205 / 255, green: 215 / 255, blue: 245 / 255))
                        .frame(width: 78, height: 78)
                    Circle()
                        .fill(StamerleeTheme.backgroundDark)
                        .frame(width: 52, height: 52)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 28)

            PrimaryActionButton(title: "Finish") {
                completeCurrentDifficulty()
                withAnimation(.easeInOut(duration: 0.25)) {
                    isAnalysisVisible = true
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var wordsList: [String] {
        switch difficulty {
        case "Medium":
            return [
                "Pathway", "Bridge", "Forest", "Walking", "Together", "Shadows",
                "Sunlight", "Reflection", "Serene", "Horizon", "Stream", "Nature",
                "Quiet", "Breeze", "Greenery", "Trail", "Landscape", "Journey"
            ]
        case "Hard":
            return [
                "Architecture", "Downtown", "Movement", "Pedestrians", "Bicycle", "Boulevard",
                "Conversation", "Vibrant", "Crossing", "Reflection", "Urban", "Momentum",
                "Atmosphere", "Dynamic", "Rhythm", "Expression", "Perspective", "Detail"
            ]
        default:
            return [
                "Sitting", "Steps", "Tree", "Light", "Golden", "Smiling",
                "Bench", "Purple", "Pet", "White", "Shoes", "People",
                "Talking", "Dog", "Building", "Friends", "Campus", "Relaxed"
            ]
        }
    }

    private var scoreText: String {
        switch difficulty {
        case "Hard":
            return "6.8"
        case "Medium":
            return "7.5"
        default:
            return "8.3"
        }
    }

    private var analysisView: some View {
        ExerciseAnalysisSkeletonView(
            scoreText: scoreText,
            maxScoreText: "/ 10",
            wordsList: wordsList,
            selectedWords: $selectedWords,
            onDone: {
                state.navigate(to: .homeDashboard)
            }
        )
    }

    private var localFallbackPath: String {
        let filename: String
        switch difficulty {
        case "Medium":
            filename = "PictureDescriptionMedium.imageset/picdesmedium.png"
        case "Hard":
            filename = "PictureDescriptionHard.imageset/picdeshard.png"
        default:
            filename = "PictureDescriptionEasy.imageset/picturedeseasy.png"
        }
        return "/Users/user15/Desktop/untitled folder/stammerlee/Stamerlee/Assets.xcassets/\(filename)"
    }

    private var loadedImage: UIImage? {
        if let image = StamerleeImageLoader.loadHeroImage(name: pictureAssetName, fallbackPath: localFallbackPath) {
            return image
        }
        if let image = StamerleeImageLoader.loadHeroImage(name: pictureAssetName, fallbackPath: "/Users/user89/Documents/stammerlee/Stamerlee/\(pictureAssetName).png") {
            return image
        }
        if let image = StamerleeImageLoader.loadHeroImage(name: "picturedes", fallbackPath: "/Users/user89/Documents/stammerlee/Stamerlee/picturedes.png") {
            return image
        }
        return nil
    }

    @ViewBuilder
    private var pictureAsset: some View {
        Group {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 34))
                            Text("Picture Description")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            }
        }
    }

    private func completeCurrentDifficulty() {
        state.completedPictureDescriptionDifficulties.insert(difficulty)
    }

    private var description: String {
        switch difficulty {
        case "Hard":
            return "Describe pictures with connected ideas,\ncomplete sentences, and natural detail"
        case "Medium":
            return "Describe pictures using longer phrases\nand clear sentence connections"
        default:
            return "Describe simple pictures using words and\nshort sentences"
        }
    }
}
