import SwiftUI

// =============================================================================
// MARK: - PROLONGED PRACTICE & ANALYSIS VIEWS
// Matches "prolonged easy level" and "pro res" screenshots
// =============================================================================

// MARK: - 1. Prolonged Easy Practice Screen ("prolonged easy level")
public struct ProlongedPracticeView: View {
    @Bindable public var state: AppState
    
    @State private var isDAFActive: Bool = false
    @State private var isListening: Bool = false
    @State private var currentWordIndex: Int = 0
    @State private var wavePulse: Bool = false
    
    private let practiceWords = [
        "“Wattttter...”",
        "“Sssssun...”",
        "“Mmmorning...”"
    ]
    
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
                        .foregroundColor(.white)
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
                    Text("Easy")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                    
                    Text("Stretch the sounds gently as you speak,\nkeeping each word slow, and relaxed")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)
                
                Spacer()
                
                // Center Practice Word Card
                VStack(spacing: 16) {
                    Text(practiceWords[currentWordIndex])
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 55 / 255, green: 95 / 255, blue: 225 / 255))
                        .frame(maxWidth: .infinity)
                        .frame(height: 76)
                        .background(
                            Color(red: 236 / 255, green: 239 / 255, blue: 252 / 255) // Soft lilac/white pill
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                currentWordIndex = (currentWordIndex + 1) % practiceWords.count
                            }
                        }
                    
                    // Dot Page Indicators for Words
                    HStack(spacing: 6) {
                        ForEach(0..<practiceWords.count, id: \.self) { i in
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
                                .foregroundColor(isListening ? StamerleeTheme.primaryBlue : .white)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 28)
                
                // Bottom CTA Button ("Finish")
                VStack {
                    PrimaryActionButton(title: "Finish") {
                        state.navigate(to: .prolongedAnalysis)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - 2. Analysis / Results Screen ("pro res")
public struct ProlongedAnalysisView: View {
    @Bindable public var state: AppState
    
    @State private var selectedSegment: String = "Blocks"
    @State private var selectedWords: Set<String> = ["Water", "University"]
    
    private let wordsList = [
        "Water", "University",
        "Breaking", "Computer",
        "Scale", "laptop"
    ]
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Title Bar
                Text("Analysis")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                
                // Big Score Display
                VStack(spacing: 6) {
                    Text("YOU SCORED")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .tracking(1.2)
                    
                    Text("86%")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 32)
                
                // Instructions Subtitle
                Text("Choose the words to practice them using Beat Buddy")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 16)
                
                // Segmented Pill Control (Blocks | Repetition)
                HStack(spacing: 0) {
                    segmentButton(title: "Blocks", isSelected: selectedSegment == "Blocks") {
                        selectedSegment = "Blocks"
                    }
                    
                    segmentButton(title: "Repetition", isSelected: selectedSegment == "Repetition") {
                        selectedSegment = "Repetition"
                    }
                }
                .padding(3)
                .background(Color(red: 220 / 255, green: 224 / 255, blue: 245 / 255))
                .clipShape(Capsule())
                .padding(.horizontal, 24)
                .padding(.bottom, 22)
                
                // 2-Column Word Grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(wordsList, id: \.self) { word in
                        let isSelected = selectedWords.contains(word)
                        wordButton(word: word, isSelected: isSelected) {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                                if selectedWords.contains(word) {
                                    selectedWords.remove(word)
                                } else {
                                    selectedWords.insert(word)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Bottom CTA Button ("Done")
                VStack {
                    PrimaryActionButton(title: "Done") {
                        state.navigate(to: .homeDashboard)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Segment Pill Button
    private func segmentButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? StamerleeTheme.textPrimaryLight : Color(red: 80 / 255, green: 85 / 255, blue: 110 / 255))
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(
                    isSelected ? Color.white : Color.clear
                )
                .clipShape(Capsule())
                .shadow(color: isSelected ? Color.black.opacity(0.08) : .clear, radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Word Selection Pill
    private func wordButton(word: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(word)
                .font(.system(size: 13.5, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : StamerleeTheme.textSecondaryDark)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    Group {
                        if isSelected {
                            Color(red: 20 / 255, green: 45 / 255, blue: 105 / 255)
                        } else {
                            Color(red: 16 / 255, green: 18 / 255, blue: 36 / 255)
                        }
                    }
                )
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? StamerleeTheme.primaryBlue : Color.white.opacity(0.06),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
