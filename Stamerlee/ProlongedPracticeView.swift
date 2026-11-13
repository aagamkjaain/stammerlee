import SwiftUI

// =============================================================================
// MARK: - PROLONGED PRACTICE & ANALYSIS VIEWS
// Matches "prolonged easy level", "prolonged medium level", and "pro res" screenshots
// =============================================================================

// MARK: - 1. Prolonged Practice Screen (Supports Easy, Medium & Hard)
public struct ProlongedPracticeView: View {
    @Bindable public var state: AppState

    private var isSentences: Bool {
        state.selectedDifficulty == "Sentences" || state.selectedDifficulty == "Medium"
    }

    private var isParagraphs: Bool {
        state.selectedDifficulty == "Paragraphs" || state.selectedDifficulty == "Hard"
    }

    private var practicePhrases: [String] {
        if isParagraphs {
            return [
                "I wwouldd rreally likke a cup of coffee",
                "The wweather is bbeautiful this morning",
                "Could you please repeat that slowly",
                "I am feeling calm and confident today"
            ]
        } else if isSentences {
            return [
                "I lovve sspiiderrmaann",
                "Ggood mmoorrning friieend",
                "Ppleease passs the waatter",
                "The trrain arrives at noon"
            ]
        } else {
            return [
                "Wattttter",
                "Sssssun",
                "Mmmorning",
                "Ppplease",
                "Ggardenn",
                "Wwindoww",
                "Bbreathe",
                "Qquiett"
            ]
        }
    }

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        SpeakPracticeScreen(
            prompts: practicePhrases,
            allowsMultilinePrompt: isSentences || isParagraphs,
            onBack: {
                state.navigate(to: .prolongedSpeechDifficulty, forward: false)
            },
            onFinish: {
                if state.selectedDifficulty == "Easy" || state.selectedDifficulty == "Words" {
                    state.hasAttemptedProlongedEasy = true
                }
                state.navigate(to: .prolongedAnalysis)
            }
        )
    }
}

// MARK: - 2. Analysis / Results Screen ("pro res" / "prolonged speech blocks...")
public struct ProlongedAnalysisView: View {
    @Bindable public var state: AppState

    private var level: String {
        state.selectedDifficulty
    }

    public init(state: AppState) {
        self.state = state
    }

    private var scoreText: String {
        switch level {
        case "Paragraphs", "Hard":
            return "7.9"
        case "Sentences", "Medium":
            return "8.5"
        default:
            return "8.8"
        }
    }

    public var body: some View {
        ExerciseAnalysisSkeletonView(
            scoreText: scoreText,
            maxScoreText: "/ 10",
            subtitle: "Great job completing your prolonged speech session!",
            onDone: {
                let score = Double(scoreText) ?? 8.8
                state.recordProlongedScore(difficulty: level, score: score)
                state.navigate(to: .homeDashboard)
            }
        )
        .onAppear {
            let score = Double(scoreText) ?? 8.8
            state.recordProlongedScore(difficulty: level, score: score)
        }
    }
}
