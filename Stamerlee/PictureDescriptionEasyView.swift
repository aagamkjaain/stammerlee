import SwiftUI

// MARK: - Picture Description Practice
/// Picture-description practice for the selected difficulty.
public struct PictureDescriptionEasyView: View {
    @Bindable public var state: AppState
    @State private var isAnalysisVisible = false
    @State private var selectedSegment = "Prolongations"
    @State private var selectedWords: Set<String> = ["Sitting", "Smiling"]

    private let wordsBySegment: [String: [String]] = [
        "Prolongations": ["Sitting", "Steps", "Tree", "Light", "Golden", "Smiling"],
        "Blocks": ["Bench", "Purple", "Golden", "Pet", "White", "Shoes"],
        "Repetitions": ["People", "Talking", "Dog", "Building", "Friends", "Campus"]
    ]

    private var difficulty: String {
        state.selectedPictureDescriptionDifficulty
    }

    private var pictureAssetName: String {
        switch difficulty {
        case "Medium":
            return "picdesmedium"
        case "Hard":
            return "picdeshard"
        default:
            return "picturedeseasy"
        }
    }

    public init(state: AppState) {
        self.state = state
    }

    private var words: [String] {
        wordsBySegment[selectedSegment] ?? []
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

            pictureAsset
                .frame(maxWidth: .infinity)
                .frame(height: 190)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            Spacer()

            Button {
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
                state.completedPictureDescriptionDifficulties.insert(difficulty)
                withAnimation(.easeInOut(duration: 0.25)) {
                    isAnalysisVisible = true
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    private var analysisView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Analysis")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 24)

            VStack(spacing: 6) {
                Text("YOU SCORED")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("68%")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 64)
            .padding(.bottom, 28)

            Text("Choose the words to practice them using Beat Buddy")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(StamerleeTheme.textSecondaryDark)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 14)

            HStack(spacing: 0) {
                ForEach(["Prolongations", "Blocks", "Repetitions"], id: \.self) { segment in
                    Button(segment) {
                        selectedSegment = segment
                        selectedWords = Set(wordsBySegment[segment, default: []].prefix(2))
                    }
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(selectedSegment == segment ? .black : .black.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(selectedSegment == segment ? .white : .clear)
                    .clipShape(Capsule())
                }
            }
            .padding(3)
            .background(Color(red: 220 / 255, green: 224 / 255, blue: 245 / 255))
            .clipShape(Capsule())
            .padding(.horizontal, 24)
            .padding(.bottom, 22)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(words, id: \.self) { word in
                    Button(word) {
                        if selectedWords.contains(word) {
                            selectedWords.remove(word)
                        } else {
                            selectedWords.insert(word)
                        }
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(selectedWords.contains(word) ? .white : StamerleeTheme.textSecondaryDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(selectedWords.contains(word) ? Color(red: 20 / 255, green: 45 / 255, blue: 105 / 255) : Color.white.opacity(0.03))
                    .overlay(Capsule().stroke(selectedWords.contains(word) ? StamerleeTheme.primaryBlue : Color.white.opacity(0.06)))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryActionButton(title: "Done") {
                state.navigate(to: .homeDashboard)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private var pictureAsset: some View {
        if let image = StamerleeImageLoader.loadHeroImage(
            name: pictureAssetName,
            fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/\(pictureAssetName).png"
        ) ?? StamerleeImageLoader.loadHeroImage(
            name: "picturedes",
            fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/picturedes.png"
        ) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 34))
                        Text("Picture Description")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                }
        }
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
