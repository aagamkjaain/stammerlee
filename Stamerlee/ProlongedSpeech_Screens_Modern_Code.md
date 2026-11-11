# Prolonged Speech Difficulty and Practice Screens

This document explains the screens shown by the prolonged-speech flow and checks whether their implementation uses modern SwiftUI/Observation patterns.

## Flow

```text
ProlongedSpeechIntroView
  -> ProlongedSpeechDifficultyView
       -> ProlongedPracticeView
            -> ProlongedAnalysisView
                 -> HomeDashboardView
```

| Screen | Responsibility | Main state/action |
|---|---|---|
| `ProlongedSpeechDifficultyView` | Shows Words, Sentences, and Paragraphs level cards. | Reads completion state and sets `selectedDifficulty`. |
| `ProlongedPracticeView` | Chooses prompts based on the selected level and starts the shared practice UI. | Sets `hasAttemptedProlongedEasy` for Easy/Words and navigates to analysis. |
| `ProlongedAnalysisView` | Displays score and selectable practice words. | Records score on appearance and completion, then returns home. |

## Modern-code check

The implementation is generally modern SwiftUI code. No definite deprecated API is present in these two files.

- `@Bindable` with the Observation-based `AppState` is modern and appropriate for shared mutable state.
- `some View`, result-builder composition, `ForEach`, and state-driven navigation are current SwiftUI patterns.
- The screens delegate reusable UI to `DifficultyCard`, `SpeakPracticeScreen`, and `ExerciseAnalysisSkeletonView`, avoiding duplicated layouts.
- The `switch`-based prompt and score selection is type-safe and easy to extend.
- `.alert(..., isPresented:)` and `.onAppear` are current APIs.
- The iOS 26 availability concern is in the shared card component, not these screen files; its fallback should remain.
- Potential behavior issue, not deprecation: `ProlongedAnalysisView.onAppear` records a score before the user taps Done, so merely opening analysis marks the level completed.
- Potential data issue, not deprecation: score strings and difficulty names are duplicated across screens; typed difficulty and score models could reduce mismatch risk.

## Line-by-line explanation

### `Stamerlee/ProlongedSpeechDifficultyView.swift` (86 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI for declarative views, state, and modifiers. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Prolonged Speech Difficulty View (Screenshot 4: "pro speech screen")` | Section marker organizing the prolonged-speech implementation. |
| 4 | `/// Difficulty selection screen for the Easy, Medium, and Hard exercises.` | Comment describing the purpose of the following code. |
| 5 | `public struct ProlongedSpeechDifficultyView: View {` | Declares a reusable public SwiftUI screen. |
| 6 | `    @Bindable public var state: AppState` | Connects the screen to the observable AppState for two-way mutation. |
| 7 | `    ` | Blank line separating code sections. |
| 8 | `    @State private var showLockedAlert: Bool = false` | Stores view-local state managed by SwiftUI. |
| 9 | `    @State private var lockedAlertText: String = ""` | Stores view-local state managed by SwiftUI. |
| 10 | `    ` | Blank line separating code sections. |
| 11 | `    public init(state: AppState) {` | Initializes the screen with shared app state. |
| 12 | `        self.state = state` | Implements the surrounding screen or view-builder expression. |
| 13 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 14 | `    ` | Blank line separating code sections. |
| 15 | `    public var body: some View {` | Defines the screen’s rendered SwiftUI hierarchy. |
| 16 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 17 | `            // Dark Background` | Comment describing the purpose of the following code. |
| 18 | `            StamerleeTheme.backgroundDark` | Implements the surrounding screen or view-builder expression. |
| 19 | `                .ignoresSafeArea()` | Extends the dark background into safe-area regions. |
| 20 | `            ` | Blank line separating code sections. |
| 21 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 22 | `                // Top Navigation Bar` | Comment describing the purpose of the following code. |
| 23 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 24 | `                    BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 25 | `                        state.navigate(to: .homeDashboard, forward: false)` | Updates the shared navigation state and moves to the requested screen. |
| 26 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 27 | `                    Spacer()` | Implements the surrounding screen or view-builder expression. |
| 28 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 29 | `                .padding(.horizontal, 24)` | Adds spacing around the view. |
| 30 | `                .padding(.top, 16)` | Adds spacing around the view. |
| 31 | `                ` | Blank line separating code sections. |
| 32 | `                // Headings` | Comment describing the purpose of the following code. |
| 33 | `                VStack(alignment: .leading, spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 34 | `                    Text("Prolonged Speech")` | Displays a text label. |
| 35 | `                        .font(.system(size: 30, weight: .bold, design: .rounded))` | Sets font size, weight, and design. |
| 36 | `                        .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the text or icon foreground style. |
| 37 | `                    ` | Blank line separating code sections. |
| 38 | `                    Text("Practice stretching sounds for smoother,more fluent speech.")` | Displays a text label. |
| 39 | `                        .font(.system(size: 14.5, weight: .regular, design: .rounded))` | Sets font size, weight, and design. |
| 40 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the text or icon foreground style. |
| 41 | `                        .lineSpacing(3)` | Applies a SwiftUI modifier to the preceding view. |
| 42 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 43 | `                .padding(.horizontal, 24)` | Adds spacing around the view. |
| 44 | `                .padding(.top, 24)` | Adds spacing around the view. |
| 45 | `                .padding(.bottom, 36)` | Adds spacing around the view. |
| 46 | `                ` | Blank line separating code sections. |
| 47 | `                // Difficulty Level Cards` | Comment describing the purpose of the following code. |
| 48 | `                VStack(spacing: 16) {` | Opens or closes a Swift scope or view-builder block. |
| 49 | `                    ForEach(["Words", "Sentences", "Paragraphs"], id: \.self) { difficulty in` | Creates one difficulty card for each level. |
| 50 | `                        difficultyCard(` | Implements the surrounding screen or view-builder expression. |
| 51 | `                            title: difficulty,` | Implements the surrounding screen or view-builder expression. |
| 52 | `                            isLocked: false,` | Implements the surrounding screen or view-builder expression. |
| 53 | `                            isCompleted: state.completedProlongedDifficulties.contains(difficulty)` | Implements the surrounding screen or view-builder expression. |
| 54 | `                        ) {` | Opens or closes a Swift scope or view-builder block. |
| 55 | `                            state.selectedDifficulty = difficulty` | Implements the surrounding screen or view-builder expression. |
| 56 | `                            state.navigate(to: .prolongedPractice)` | Updates the shared navigation state and moves to the requested screen. |
| 57 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 58 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 59 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 60 | `                .padding(.horizontal, 20)` | Adds spacing around the view. |
| 61 | `                ` | Blank line separating code sections. |
| 62 | `                Spacer()` | Implements the surrounding screen or view-builder expression. |
| 63 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 64 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 65 | `        .alert("Level Locked", isPresented: $showLockedAlert) {` | Presents a locked-level alert controlled by local state. |
| 66 | `            Button("Got it", role: .cancel) {}` | Creates an interactive button. |
| 67 | `        } message: {` | Opens or closes a Swift scope or view-builder block. |
| 68 | `            Text(lockedAlertText)` | Displays a text label. |
| 69 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 70 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 71 | `    ` | Blank line separating code sections. |
| 72 | `    // MARK: - Difficulty Card` | Section marker organizing the prolonged-speech implementation. |
| 73 | `    private func difficultyCard(` | Defines a private view-building or behavior helper. |
| 74 | `        title: String,` | Implements the surrounding screen or view-builder expression. |
| 75 | `        isLocked: Bool,` | Implements the surrounding screen or view-builder expression. |
| 76 | `        isCompleted: Bool,` | Implements the surrounding screen or view-builder expression. |
| 77 | `        action: @escaping () -> Void` | Implements the surrounding screen or view-builder expression. |
| 78 | `    ) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 79 | `        DifficultyCard(` | Reuses the shared difficulty card component. |
| 80 | `            title: title,` | Implements the surrounding screen or view-builder expression. |
| 81 | `            isLocked: isLocked,` | Implements the surrounding screen or view-builder expression. |
| 82 | `            isCompleted: isCompleted,` | Implements the surrounding screen or view-builder expression. |
| 83 | `            action: action` | Implements the surrounding screen or view-builder expression. |
| 84 | `        )` | Implements the surrounding screen or view-builder expression. |
| 85 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 86 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/ProlongedPracticeView.swift` (136 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI for declarative views, state, and modifiers. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// =============================================================================` | Section marker organizing the prolonged-speech implementation. |
| 4 | `// MARK: - PROLONGED PRACTICE & ANALYSIS VIEWS` | Section marker organizing the prolonged-speech implementation. |
| 5 | `// Matches "prolonged easy level", "prolonged medium level", and "pro res" screenshots` | Comment describing the purpose of the following code. |
| 6 | `// =============================================================================` | Section marker organizing the prolonged-speech implementation. |
| 7 | `` | Blank line separating code sections. |
| 8 | `// MARK: - 1. Prolonged Practice Screen (Supports Easy, Medium & Hard)` | Section marker organizing the prolonged-speech implementation. |
| 9 | `public struct ProlongedPracticeView: View {` | Declares a reusable public SwiftUI screen. |
| 10 | `    @Bindable public var state: AppState` | Connects the screen to the observable AppState for two-way mutation. |
| 11 | `` | Blank line separating code sections. |
| 12 | `    private var isSentences: Bool {` | Defines a computed helper value used by the screen. |
| 13 | `        state.selectedDifficulty == "Sentences" \|\| state.selectedDifficulty == "Medium"` | Implements the surrounding screen or view-builder expression. |
| 14 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 15 | `` | Blank line separating code sections. |
| 16 | `    private var isParagraphs: Bool {` | Defines a computed helper value used by the screen. |
| 17 | `        state.selectedDifficulty == "Paragraphs" \|\| state.selectedDifficulty == "Hard"` | Implements the surrounding screen or view-builder expression. |
| 18 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 19 | `` | Blank line separating code sections. |
| 20 | `    private var practicePhrases: [String] {` | Defines a computed helper value used by the screen. |
| 21 | `        if isParagraphs {` | Conditionally selects this behavior or data set. |
| 22 | `            return [` | Returns the computed value or view. |
| 23 | `                "I wwouldd rreally likke a cup of coffee",` | Implements the surrounding screen or view-builder expression. |
| 24 | `                "The wweather is bbeautiful this morning",` | Implements the surrounding screen or view-builder expression. |
| 25 | `                "Could you please repeat that slowly",` | Implements the surrounding screen or view-builder expression. |
| 26 | `                "I am feeling calm and confident today"` | Implements the surrounding screen or view-builder expression. |
| 27 | `            ]` | Implements the surrounding screen or view-builder expression. |
| 28 | `        } else if isSentences {` | Opens or closes a Swift scope or view-builder block. |
| 29 | `            return [` | Returns the computed value or view. |
| 30 | `                "I lovve sspiiderrmaann",` | Implements the surrounding screen or view-builder expression. |
| 31 | `                "Ggood mmoorrning friieend",` | Implements the surrounding screen or view-builder expression. |
| 32 | `                "Ppleease passs the waatter",` | Implements the surrounding screen or view-builder expression. |
| 33 | `                "The trrain arrives at noon"` | Implements the surrounding screen or view-builder expression. |
| 34 | `            ]` | Implements the surrounding screen or view-builder expression. |
| 35 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 36 | `            return [` | Returns the computed value or view. |
| 37 | `                "Wattttter",` | Implements the surrounding screen or view-builder expression. |
| 38 | `                "Sssssun",` | Implements the surrounding screen or view-builder expression. |
| 39 | `                "Mmmorning",` | Implements the surrounding screen or view-builder expression. |
| 40 | `                "Ppplease",` | Implements the surrounding screen or view-builder expression. |
| 41 | `                "Ggardenn",` | Implements the surrounding screen or view-builder expression. |
| 42 | `                "Wwindoww",` | Implements the surrounding screen or view-builder expression. |
| 43 | `                "Bbreathe",` | Implements the surrounding screen or view-builder expression. |
| 44 | `                "Qquiett"` | Implements the surrounding screen or view-builder expression. |
| 45 | `            ]` | Implements the surrounding screen or view-builder expression. |
| 46 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 47 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 48 | `` | Blank line separating code sections. |
| 49 | `    public init(state: AppState) {` | Initializes the screen with shared app state. |
| 50 | `        self.state = state` | Implements the surrounding screen or view-builder expression. |
| 51 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 52 | `` | Blank line separating code sections. |
| 53 | `    public var body: some View {` | Defines the screen’s rendered SwiftUI hierarchy. |
| 54 | `        SpeakPracticeScreen(` | Delegates practice rendering to the shared speech-practice screen. |
| 55 | `            prompts: practicePhrases,` | Implements the surrounding screen or view-builder expression. |
| 56 | `            allowsMultilinePrompt: isSentences \|\| isParagraphs,` | Implements the surrounding screen or view-builder expression. |
| 57 | `            onBack: {` | Opens or closes a Swift scope or view-builder block. |
| 58 | `                state.navigate(to: .prolongedSpeechDifficulty, forward: false)` | Updates the shared navigation state and moves to the requested screen. |
| 59 | `            },` | Implements the surrounding screen or view-builder expression. |
| 60 | `            onFinish: {` | Opens or closes a Swift scope or view-builder block. |
| 61 | `                if state.selectedDifficulty == "Easy" \|\| state.selectedDifficulty == "Words" {` | Conditionally selects this behavior or data set. |
| 62 | `                    state.hasAttemptedProlongedEasy = true` | Records that the Easy/Words level has been attempted. |
| 63 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 64 | `                state.navigate(to: .prolongedAnalysis)` | Updates the shared navigation state and moves to the requested screen. |
| 65 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 66 | `        )` | Implements the surrounding screen or view-builder expression. |
| 67 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 68 | `}` | Opens or closes a Swift scope or view-builder block. |
| 69 | `` | Blank line separating code sections. |
| 70 | `// MARK: - 2. Analysis / Results Screen ("pro res" / "prolonged speech blocks...")` | Section marker organizing the prolonged-speech implementation. |
| 71 | `public struct ProlongedAnalysisView: View {` | Declares a reusable public SwiftUI screen. |
| 72 | `    @Bindable public var state: AppState` | Connects the screen to the observable AppState for two-way mutation. |
| 73 | `    ` | Blank line separating code sections. |
| 74 | `    @State private var selectedWords: Set<String> = []` | Stores view-local state managed by SwiftUI. |
| 75 | `    ` | Blank line separating code sections. |
| 76 | `    private var level: String {` | Defines a computed helper value used by the screen. |
| 77 | `        state.selectedDifficulty` | Implements the surrounding screen or view-builder expression. |
| 78 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 79 | `` | Blank line separating code sections. |
| 80 | `    private var wordsList: [String] {` | Defines a computed helper value used by the screen. |
| 81 | `        switch level {` | Selects data based on the current difficulty level. |
| 82 | `        case "Sentences", "Medium":` | Handles one difficulty-level case. |
| 83 | `            return [` | Returns the computed value or view. |
| 84 | `                "Love", "Spiderman", "Please", "Water", "Morning", "Friend",` | Implements the surrounding screen or view-builder expression. |
| 85 | `                "Together", "Sentence", "Adventure", "Courage", "Family", "Journey",` | Implements the surrounding screen or view-builder expression. |
| 86 | `                "Comfort", "Practice", "Freedom", "Balance", "Connect", "Progress"` | Implements the surrounding screen or view-builder expression. |
| 87 | `            ]` | Implements the surrounding screen or view-builder expression. |
| 88 | `        case "Paragraphs", "Hard":` | Handles one difficulty-level case. |
| 89 | `            return [` | Returns the computed value or view. |
| 90 | `                "Really", "Weather", "Coffee", "Repeat", "Slowly", "Feeling",` | Implements the surrounding screen or view-builder expression. |
| 91 | `                "Would", "Natural", "Connection", "Confidence", "Today", "Pacing",` | Implements the surrounding screen or view-builder expression. |
| 92 | `                "Conversation", "Expressive", "Overcome", "Clarity", "Smoothness", "Resilience"` | Implements the surrounding screen or view-builder expression. |
| 93 | `            ]` | Implements the surrounding screen or view-builder expression. |
| 94 | `        default: // Words / Easy` | Handles the default Words/Easy behavior. |
| 95 | `            return [` | Returns the computed value or view. |
| 96 | `                "Water", "Sun", "Morning", "Please", "Garden", "Window",` | Implements the surrounding screen or view-builder expression. |
| 97 | `                "Slowly", "Relaxed", "Together", "Gentle", "Quiet", "Breathe",` | Implements the surrounding screen or view-builder expression. |
| 98 | `                "Listen", "River", "Sunny", "Simple", "Golden", "Peaceful"` | Implements the surrounding screen or view-builder expression. |
| 99 | `            ]` | Implements the surrounding screen or view-builder expression. |
| 100 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 101 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 102 | `    ` | Blank line separating code sections. |
| 103 | `    public init(state: AppState) {` | Initializes the screen with shared app state. |
| 104 | `        self.state = state` | Implements the surrounding screen or view-builder expression. |
| 105 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 106 | `    ` | Blank line separating code sections. |
| 107 | `    private var scoreText: String {` | Defines a computed helper value used by the screen. |
| 108 | `        switch level {` | Selects data based on the current difficulty level. |
| 109 | `        case "Paragraphs", "Hard":` | Handles one difficulty-level case. |
| 110 | `            return "7.9"` | Returns the computed value or view. |
| 111 | `        case "Sentences", "Medium":` | Handles one difficulty-level case. |
| 112 | `            return "8.5"` | Returns the computed value or view. |
| 113 | `        default:` | Handles the default Words/Easy behavior. |
| 114 | `            return "8.8"` | Returns the computed value or view. |
| 115 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 116 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 117 | `` | Blank line separating code sections. |
| 118 | `    public var body: some View {` | Defines the screen’s rendered SwiftUI hierarchy. |
| 119 | `        ExerciseAnalysisSkeletonView(` | Reuses the shared analysis screen with score, word selection, and completion behavior. |
| 120 | `            scoreText: scoreText,` | Implements the surrounding screen or view-builder expression. |
| 121 | `            maxScoreText: "/ 10",` | Implements the surrounding screen or view-builder expression. |
| 122 | `            wordsList: wordsList,` | Implements the surrounding screen or view-builder expression. |
| 123 | `            selectedWords: $selectedWords,` | Implements the surrounding screen or view-builder expression. |
| 124 | `            onDone: {` | Opens or closes a Swift scope or view-builder block. |
| 125 | `                let score = Double(scoreText) ?? 8.8` | Declares an immutable local or stored value. |
| 126 | `                state.recordProlongedScore(difficulty: level, score: score)` | Stores the score and marks the selected difficulty as completed in AppState. |
| 127 | `                state.navigate(to: .homeDashboard)` | Updates the shared navigation state and moves to the requested screen. |
| 128 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 129 | `        )` | Implements the surrounding screen or view-builder expression. |
| 130 | `        .onAppear {` | Runs initialization when the results screen becomes visible. |
| 131 | `            selectedWords = Set(wordsList.prefix(2))` | Implements the surrounding screen or view-builder expression. |
| 132 | `            let score = Double(scoreText) ?? 8.8` | Declares an immutable local or stored value. |
| 133 | `            state.recordProlongedScore(difficulty: level, score: score)` | Stores the score and marks the selected difficulty as completed in AppState. |
| 134 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 135 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 136 | `}` | Opens or closes a Swift scope or view-builder block. |

## Shared components used

- [Components.swift](./Components.swift): `DifficultyCard` renders level cards, `ExerciseAnalysisSkeletonView` renders results, and `SpeechMicrophoneButton` supports speech controls used by related practice screens.
- [ProlongedSpeechIntroView.swift](./ProlongedSpeechIntroView.swift): marks `hasSeenProlongedSpeechIntro` and routes into this flow.
- [AppScreen.swift](./AppScreen.swift): declares the screen cases and stores the shared `AppState`.

## Recommended modern refinements

1. Move difficulty labels, prompts, and scores into a typed model instead of comparing raw strings.
2. Record the score only on the explicit Done action unless opening the analysis screen is intentionally treated as completion.
3. Replace unused locked-alert plumbing if all levels are intentionally unlocked, or wire it to real unlock rules.
