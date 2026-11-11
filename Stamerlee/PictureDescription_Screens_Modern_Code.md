# Picture Description Screens: Modern SwiftUI Review

This document reviews the picture-description screens shown in the supplied screenshot. The repository file named `PictureDescriptionDifficultyView.swift` actually contains `PictureDescriptionIntroView`; the difficulty/practice implementation is in `PictureDescriptionEasyView.swift`.

## Screen flow

```text
HomeDashboardView
  -> PictureDescriptionIntroView
       -> PictureDescriptionEasyView
            -> ExerciseAnalysisSkeletonView
                 -> HomeDashboardView
```

## Modern-code check

The implementation uses modern SwiftUI and Observation patterns. No definite deprecated API is present in these files.

- `@Bindable` with `AppState` is the modern Observation-based approach for shared mutable state.
- `some View`, computed view properties, `switch`, and state-driven conditional rendering are current SwiftUI patterns.
- `SpeechMicrophoneButton` and `ExerciseAnalysisSkeletonView` are reused instead of duplicating interaction and results UI.
- `.alert` is not used directly in these two files; navigation and completion are delegated to shared state and components.
- `.accessibilityLabel("Picture to describe")` is a good modern accessibility practice for meaningful artwork.
- Potential behavior issue, not deprecation: `isListening` is set to `true` but is not reset when analysis appears.
- Potential behavior issue, not deprecation: `isAnalysisVisible` swaps subviews locally instead of navigating to the `pictureDescriptionPractice`/analysis route.
- The raw difficulty strings (`Easy`, `Medium`, `Hard`) are workable but a typed enum would be safer.

## Line-by-line explanation

### `Stamerlee/PictureDescriptionEasyView.swift` (173 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI for declarative views, state, and modifiers. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Picture Description Practice` | Section marker organizing the picture-description implementation. |
| 4 | `/// Picture-description practice for the selected difficulty.` | Comment describing the purpose of the following code. |
| 5 | `public struct PictureDescriptionEasyView: View {` | Declares a reusable public SwiftUI screen. |
| 6 | `    @Bindable public var state: AppState` | Connects the screen to the observable AppState for two-way mutation. |
| 7 | `    @State private var isAnalysisVisible = false` | Stores view-local state managed by SwiftUI. |
| 8 | `    @State private var isListening = false` | Stores view-local state managed by SwiftUI. |
| 9 | `` | Blank line separating code sections. |
| 10 | `    private var difficulty: String {` | Defines a computed helper value or subview. |
| 11 | `        state.selectedPictureDescriptionDifficulty` | Implements the surrounding screen or view-builder expression. |
| 12 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 13 | `` | Blank line separating code sections. |
| 14 | `    private var pictureAssetName: String {` | Defines a computed helper value or subview. |
| 15 | `        switch difficulty {` | Selects content based on the selected difficulty. |
| 16 | `        case "Medium":` | Handles one difficulty case. |
| 17 | `            return "PictureDescriptionMedium"` | Returns the computed value or view. |
| 18 | `        case "Hard":` | Handles one difficulty case. |
| 19 | `            return "PictureDescriptionHard"` | Returns the computed value or view. |
| 20 | `        default:` | Handles the default Easy difficulty. |
| 21 | `            return "PictureDescriptionEasy"` | Returns the computed value or view. |
| 22 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 23 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 24 | `` | Blank line separating code sections. |
| 25 | `    public init(state: AppState) {` | Initializes the screen with shared app state. |
| 26 | `        self.state = state` | Implements the surrounding screen or view-builder expression. |
| 27 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 28 | `` | Blank line separating code sections. |
| 29 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 30 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 31 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen or view-builder expression. |
| 32 | `` | Blank line separating code sections. |
| 33 | `            if isAnalysisVisible {` | Conditionally selects this branch. |
| 34 | `                analysisView` | Implements the surrounding screen or view-builder expression. |
| 35 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 36 | `                practiceView` | Implements the surrounding screen or view-builder expression. |
| 37 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 38 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 39 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 40 | `` | Blank line separating code sections. |
| 41 | `    private var practiceView: some View {` | Defines a computed helper value or subview. |
| 42 | `        VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 43 | `            HStack {` | Opens or closes a Swift scope or view-builder block. |
| 44 | `                BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 45 | `                    state.navigate(to: .homeDashboard, forward: false)` | Updates shared navigation state and moves to the requested screen. |
| 46 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 47 | `                Spacer()` | Implements the surrounding screen or view-builder expression. |
| 48 | `                Text("DAF")` | Implements the surrounding screen or view-builder expression. |
| 49 | `                    .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 50 | `                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 51 | `                    .padding(.horizontal, 16)` | Adds layout spacing around the view. |
| 52 | `                    .padding(.vertical, 8)` | Adds layout spacing around the view. |
| 53 | `                    .background(StamerleeTheme.primaryBlueDark)` | Adds a background behind the content. |
| 54 | `                    .clipShape(Capsule())` | Clips the image to a rounded rectangle. |
| 55 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 56 | `            .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 57 | `            .padding(.top, 16)` | Adds layout spacing around the view. |
| 58 | `` | Blank line separating code sections. |
| 59 | `            Text("Picture Description")` | Implements the surrounding screen or view-builder expression. |
| 60 | `                .font(.system(size: 30, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 61 | `                .foregroundStyle(.white)` | Sets the foreground color or style. |
| 62 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 63 | `                .padding(.top, 20)` | Adds layout spacing around the view. |
| 64 | `` | Blank line separating code sections. |
| 65 | `            Text(description)` | Implements the surrounding screen or view-builder expression. |
| 66 | `                .font(.system(size: 14, design: .rounded))` | Sets typography, size, weight, and design. |
| 67 | `                .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 68 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 69 | `                .padding(.top, 10)` | Adds layout spacing around the view. |
| 70 | `` | Blank line separating code sections. |
| 71 | `            Spacer(minLength: 16)` | Implements the surrounding screen or view-builder expression. |
| 72 | `` | Blank line separating code sections. |
| 73 | `            pictureAsset` | Implements the surrounding screen or view-builder expression. |
| 74 | `                .frame(maxWidth: .infinity, alignment: .center)` | Constrains the view size or alignment. |
| 75 | `                .padding(.horizontal, 20)` | Adds layout spacing around the view. |
| 76 | `` | Blank line separating code sections. |
| 77 | `            Spacer(minLength: 16)` | Implements the surrounding screen or view-builder expression. |
| 78 | `` | Blank line separating code sections. |
| 79 | `            SpeechMicrophoneButton(isListening: $isListening) {` | Uses the shared microphone/listening control. |
| 80 | `                isListening = true` | Implements the surrounding screen or view-builder expression. |
| 81 | `                completeCurrentDifficulty()` | Implements the surrounding screen or view-builder expression. |
| 82 | `                withAnimation(.easeInOut(duration: 0.25)) {` | Animates the enclosed state mutation. |
| 83 | `                    isAnalysisVisible = true` | Implements the surrounding screen or view-builder expression. |
| 84 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 85 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 86 | `            .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 87 | `            .padding(.bottom, 28)` | Adds layout spacing around the view. |
| 88 | `` | Blank line separating code sections. |
| 89 | `            PrimaryActionButton(title: "Finish") {` | Opens or closes a Swift scope or view-builder block. |
| 90 | `                completeCurrentDifficulty()` | Implements the surrounding screen or view-builder expression. |
| 91 | `                withAnimation(.easeInOut(duration: 0.25)) {` | Animates the enclosed state mutation. |
| 92 | `                    isAnalysisVisible = true` | Implements the surrounding screen or view-builder expression. |
| 93 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 94 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 95 | `            .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 96 | `            .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 97 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 98 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 99 | `` | Blank line separating code sections. |
| 100 | `    private var wordsList: [String] {` | Defines a computed helper value or subview. |
| 101 | `        switch difficulty {` | Selects content based on the selected difficulty. |
| 102 | `        case "Medium":` | Handles one difficulty case. |
| 103 | `            return [` | Returns the computed value or view. |
| 104 | `                "Pathway", "Bridge", "Forest", "Walking", "Together", "Shadows",` | Implements the surrounding screen or view-builder expression. |
| 105 | `                "Sunlight", "Reflection", "Serene", "Horizon", "Stream", "Nature",` | Implements the surrounding screen or view-builder expression. |
| 106 | `                "Quiet", "Breeze", "Greenery", "Trail", "Landscape", "Journey"` | Implements the surrounding screen or view-builder expression. |
| 107 | `            ]` | Implements the surrounding screen or view-builder expression. |
| 108 | `        case "Hard":` | Handles one difficulty case. |
| 109 | `            return [` | Returns the computed value or view. |
| 110 | `                "Architecture", "Downtown", "Movement", "Pedestrians", "Bicycle", "Boulevard",` | Implements the surrounding screen or view-builder expression. |
| 111 | `                "Conversation", "Vibrant", "Crossing", "Reflection", "Urban", "Momentum",` | Implements the surrounding screen or view-builder expression. |
| 112 | `                "Atmosphere", "Dynamic", "Rhythm", "Expression", "Perspective", "Detail"` | Implements the surrounding screen or view-builder expression. |
| 113 | `            ]` | Implements the surrounding screen or view-builder expression. |
| 114 | `        default:` | Handles the default Easy difficulty. |
| 115 | `            return [` | Returns the computed value or view. |
| 116 | `                "Sitting", "Steps", "Tree", "Light", "Golden", "Smiling",` | Implements the surrounding screen or view-builder expression. |
| 117 | `                "Bench", "Purple", "Pet", "White", "Shoes", "People",` | Implements the surrounding screen or view-builder expression. |
| 118 | `                "Talking", "Dog", "Building", "Friends", "Campus", "Relaxed"` | Implements the surrounding screen or view-builder expression. |
| 119 | `            ]` | Implements the surrounding screen or view-builder expression. |
| 120 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 121 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 122 | `` | Blank line separating code sections. |
| 123 | `    private var scoreText: String {` | Defines a computed helper value or subview. |
| 124 | `        switch difficulty {` | Selects content based on the selected difficulty. |
| 125 | `        case "Hard":` | Handles one difficulty case. |
| 126 | `            return "6.8"` | Returns the computed value or view. |
| 127 | `        case "Medium":` | Handles one difficulty case. |
| 128 | `            return "7.5"` | Returns the computed value or view. |
| 129 | `        default:` | Handles the default Easy difficulty. |
| 130 | `            return "8.3"` | Returns the computed value or view. |
| 131 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 132 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 133 | `` | Blank line separating code sections. |
| 134 | `    private var analysisView: some View {` | Defines a computed helper value or subview. |
| 135 | `        ExerciseAnalysisSkeletonView(` | Reuses the shared score and analysis layout. |
| 136 | `            scoreText: scoreText,` | Implements the surrounding screen or view-builder expression. |
| 137 | `            maxScoreText: "/ 10",` | Implements the surrounding screen or view-builder expression. |
| 138 | `            onDone: {` | Opens or closes a Swift scope or view-builder block. |
| 139 | `                state.navigate(to: .homeDashboard)` | Updates shared navigation state and moves to the requested screen. |
| 140 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 141 | `        )` | Implements the surrounding screen or view-builder expression. |
| 142 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 143 | `` | Blank line separating code sections. |
| 144 | `    private var pictureAsset: some View {` | Defines a computed helper value or subview. |
| 145 | `        Image(pictureAssetName)` | Implements the surrounding screen or view-builder expression. |
| 146 | `            .resizable()` | Applies a SwiftUI modifier to the preceding view. |
| 147 | `            .scaledToFit()` | Applies a SwiftUI modifier to the preceding view. |
| 148 | `            .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 149 | `            .frame(maxHeight: 280)` | Constrains the view size or alignment. |
| 150 | `            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))` | Clips the image to a rounded rectangle. |
| 151 | `            .overlay(` | Draws a border or additional view above the image. |
| 152 | `                RoundedRectangle(cornerRadius: 20, style: .continuous)` | Implements the surrounding screen or view-builder expression. |
| 153 | `                    .stroke(Color.white.opacity(0.12), lineWidth: 1)` | Applies a SwiftUI modifier to the preceding view. |
| 154 | `            )` | Implements the surrounding screen or view-builder expression. |
| 155 | `            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)` | Adds visual depth with a shadow. |
| 156 | `            .accessibilityLabel("Picture to describe")` | Adds accessibility semantics for assistive technologies. |
| 157 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 158 | `` | Blank line separating code sections. |
| 159 | `    private func completeCurrentDifficulty() {` | Defines a private helper for screen behavior. |
| 160 | `        state.completePictureDescription()` | Marks picture-description work as completed in AppState. |
| 161 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 162 | `` | Blank line separating code sections. |
| 163 | `    private var description: String {` | Defines a computed helper value or subview. |
| 164 | `        switch difficulty {` | Selects content based on the selected difficulty. |
| 165 | `        case "Hard":` | Handles one difficulty case. |
| 166 | `            return "Describe pictures with connected ideas,\ncomplete sentences, and natural detail"` | Returns the computed value or view. |
| 167 | `        case "Medium":` | Handles one difficulty case. |
| 168 | `            return "Describe pictures using longer phrases\nand clear sentence connections"` | Returns the computed value or view. |
| 169 | `        default:` | Handles the default Easy difficulty. |
| 170 | `            return "Describe simple pictures using words and\nshort sentences"` | Returns the computed value or view. |
| 171 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 172 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 173 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/PictureDescriptionDifficultyView.swift` (26 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI for declarative views, state, and modifiers. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Picture Description Intro View` | Section marker organizing the picture-description implementation. |
| 4 | `/// Introduces the Picture Description fluency and spontaneous expression technique.` | Comment describing the purpose of the following code. |
| 5 | `public struct PictureDescriptionIntroView: View {` | Declares a reusable public SwiftUI screen. |
| 6 | `    @Bindable public var state: AppState` | Connects the screen to the observable AppState for two-way mutation. |
| 7 | `` | Blank line separating code sections. |
| 8 | `    public init(state: AppState) {` | Initializes the screen with shared app state. |
| 9 | `        self.state = state` | Implements the surrounding screen or view-builder expression. |
| 10 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 11 | `` | Blank line separating code sections. |
| 12 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 13 | `        ExerciseIntroSkeletonView(` | Reuses the shared exercise introduction layout. |
| 14 | `            title: "Let's start with\nPicture Description",` | Implements the surrounding screen or view-builder expression. |
| 15 | `            subtitle: "Picture Description helps you turn what you see into words, organise your thoughts and express ideas more confidently in everyday conversations.",` | Implements the surrounding screen or view-builder expression. |
| 16 | `            heroImageName: "PictureHero",` | Implements the surrounding screen or view-builder expression. |
| 17 | `            onBack: {` | Opens or closes a Swift scope or view-builder block. |
| 18 | `                state.navigate(to: .homeDashboard, forward: false)` | Updates shared navigation state and moves to the requested screen. |
| 19 | `            },` | Implements the surrounding screen or view-builder expression. |
| 20 | `            onContinue: {` | Opens or closes a Swift scope or view-builder block. |
| 21 | `                state.hasSeenPictureDescriptionIntro = true` | Implements the surrounding screen or view-builder expression. |
| 22 | `                state.navigate(to: .pictureDescriptionPractice)` | Updates shared navigation state and moves to the requested screen. |
| 23 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 24 | `        )` | Implements the surrounding screen or view-builder expression. |
| 25 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 26 | `}` | Opens or closes a Swift scope or view-builder block. |

## Recommendations

- Rename `PictureDescriptionDifficultyView.swift` to match its `PictureDescriptionIntroView` declaration, or rename the declaration if the file is intended to represent difficulty selection.
- Replace difficulty strings with a `PictureDescriptionDifficulty` enum that owns asset name, description, words, and score.
- Reset `isListening` when recording finishes or when the view disappears if the microphone state becomes real.
- Persist the calculated score through `AppState` when the analysis completes if picture-description scores are needed later.
