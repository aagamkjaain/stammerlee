import SwiftUI

// =============================================================================
// MARK: - PROLONGED PRACTICE & ANALYSIS VIEWS
// Matches "prolonged easy level", "prolonged medium level", and "pro res" screenshots
// =============================================================================

// MARK: - 1. Prolonged Practice Screen (Supports Easy, Medium & Hard)
public struct ProlongedPracticeView: View {
    @Bindable public var state: AppState
    
    @State private var isDAFActive: Bool = false
    @State private var isListening: Bool = false
    @State private var currentWordIndex: Int = 0
    @State private var wavePulse: Bool = false
    
    private var isMedium: Bool {
        state.selectedDifficulty == "Medium"
    }

    private var isHard: Bool {
        state.selectedDifficulty == "Hard"
    }

    private var practicePhrases: [String] {
        if isHard {
            return [
                "“I wwouldd rreally likke a cup of coffee”",
                "“The wweather is bbeautiful this morning”",
                "“Could you please repeat that slowly”",
                "“I am feeling calm and confident today”"
            ]
        } else if isMedium {
            return [
                "“I lovve sspiiderrmaann”",
                "“Ggood mmoorrning friieend”",
                "“Ppleease passs the waatter”",
                "“The trrain arrives at noon”"
            ]
        } else {
            return [
                "“Wattttter...”",
                "“Sssssun...”",
                "“Mmmorning...”",
                "“Ppplease...”"
            ]
        }
    }

    private var levelDescription: String {
        if isHard {
            return "Build fluency with longer passages,\nconnections, and natural pacing"
        } else if isMedium {
            return "Practice stretching sounds in longer\nphrases and everyday sentences"
        }
        return "Stretch the sounds gently as you speak,\nkeeping each word slow, and relaxed"
    }
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Bar with Back Button and DAF Toggle
                HStack {
                    BackNavButton {
                        state.navigate(to: .prolongedSpeechDifficulty, forward: false)
                    }
                    
                    Spacer()
                    
                    // DAF (Delayed Auditory Feedback) Button
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isDAFActive.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "headphones")
                                .font(.system(size: 14, weight: .bold))
                            
                            Text("DAF")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            isDAFActive
                            ? StamerleeTheme.primaryBlue
                            : Color(red: 25 / 255, green: 55 / 255, blue: 130 / 255)
                        )
                        .clipShape(Capsule())
                        .shadow(color: isDAFActive ? StamerleeTheme.primaryBlue.opacity(0.4) : .clear, radius: 8, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Headings
                VStack(alignment: .leading, spacing: 8) {
                    Text(state.selectedDifficulty)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    
                    Text(levelDescription)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryDark)
                    .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)
                
                Spacer()
                
                // Center Practice Phrase Card
                VStack(spacing: 16) {
                    Text(practicePhrases[min(currentWordIndex, practicePhrases.count - 1)])
                        .font(.system(size: isHard ? 21 : (isMedium ? 23 : 26), weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 55 / 255, green: 95 / 255, blue: 225 / 255))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .frame(height: 76)
                        .background(
                            Color(red: 236 / 255, green: 239 / 255, blue: 252 / 255) // Soft lilac/white pill
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                currentWordIndex = (currentWordIndex + 1) % practicePhrases.count
                            }
                        }
                    
                    // Dot Page Indicators for Words
                    HStack(spacing: 6) {
                        ForEach(0..<practicePhrases.count, id: \.self) { i in
                            Circle()
                                .fill(i == currentWordIndex ? Color.white : Color.white.opacity(0.3))
                                .frame(width: i == currentWordIndex ? 7 : 5, height: i == currentWordIndex ? 7 : 5)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Concentric Circular Microphone Button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                        impact.impactOccurred()
                        if state.selectedDifficulty == "Easy" {
                            state.hasAttemptedProlongedEasy = true
                        }
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                            isListening.toggle()
                            wavePulse = isListening
                        }
                    }) {
                        ZStack {
                            // Outer Wave Ring
                            if isListening {
                                Circle()
                                    .stroke(StamerleeTheme.primaryBlue.opacity(0.5), lineWidth: 3)
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(wavePulse ? 1.15 : 0.95)
                                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: wavePulse)
                            }
                            
                            // Outer Soft Periwinkle Ring
                            Circle()
                                .fill(Color(red: 205 / 255, green: 215 / 255, blue: 245 / 255))
                                .frame(width: 96, height: 96)
                                .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
                            
                            // Inner Dark Circle
                            Circle()
                                .fill(Color(red: 18 / 255, green: 22 / 255, blue: 45 / 255))
                                .frame(width: 62, height: 62)
                            
                            // White Microphone Icon
                            Image(systemName: "mic.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(isListening ? StamerleeTheme.primaryBlue : .white)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 28)
                
                // Bottom CTA Button ("Finish")
                VStack {
                    PrimaryActionButton(title: "Finish") {
                        if state.selectedDifficulty == "Easy" {
                            state.hasAttemptedProlongedEasy = true
                        }
                        state.navigate(to: .prolongedAnalysis)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            currentWordIndex = 0
        }
    }
}

// MARK: - 2. Analysis / Results Screen ("pro res" / "prolonged speech blocks...")
public struct ProlongedAnalysisView: View {
    @Bindable public var state: AppState
    
    @State private var selectedWords: Set<String> = []
    
    private var level: String {
        state.selectedDifficulty
    }

    private var wordsList: [String] {
        switch level {
        case "Medium":
            return [
                "Love", "Spiderman", "Please", "Water", "Morning", "Friend",
                "Together", "Sentence", "Adventure", "Courage", "Family", "Journey",
                "Comfort", "Practice", "Freedom", "Balance", "Connect", "Progress"
            ]
        case "Hard":
            return [
                "Really", "Weather", "Coffee", "Repeat", "Slowly", "Feeling",
                "Would", "Natural", "Connection", "Confidence", "Today", "Pacing",
                "Conversation", "Expressive", "Overcome", "Clarity", "Smoothness", "Resilience"
            ]
        default: // Easy
            return [
                "Water", "Sun", "Morning", "Please", "Garden", "Window",
                "Slowly", "Relaxed", "Together", "Gentle", "Quiet", "Breathe",
                "Listen", "River", "Sunny", "Simple", "Golden", "Peaceful"
            ]
        }
    }
    
    public init(state: AppState) {
        self.state = state
    }
    
    private var scoreText: String {
        switch level {
        case "Hard":
            return "7.9"
        case "Medium":
            return "8.5"
        default:
            return "8.8"
        }
    }

    public var body: some View {
        ExerciseAnalysisSkeletonView(
            scoreText: scoreText,
            maxScoreText: "/ 10",
            wordsList: wordsList,
            selectedWords: $selectedWords,
            onDone: {
                let score = Double(scoreText) ?? 8.8
                state.recordProlongedScore(difficulty: level, score: score)
                state.navigate(to: .homeDashboard)
            }
        )
        .onAppear {
            selectedWords = Set(wordsList.prefix(2))
            let score = Double(scoreText) ?? 8.8
            state.recordProlongedScore(difficulty: level, score: score)
        }
    }
}
