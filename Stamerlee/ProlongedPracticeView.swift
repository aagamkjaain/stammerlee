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
                    Text(state.selectedDifficulty)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                    
                    Text(levelDescription)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)
                
                Spacer()
                
                // Center Practice Phrase Card
                VStack(spacing: 16) {
                    Text(practicePhrases[min(currentWordIndex, practicePhrases.count - 1)])
                        .font(.system(size: isHard ? 21 : (isMedium ? 23 : 26), weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 55 / 255, green: 95 / 255, blue: 225 / 255))
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
                        state.completeProlongedDifficulty(state.selectedDifficulty)
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
    @State private var showAllWordsSheet: Bool = false
    
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
                    .padding(.bottom, 28)
                
                // Big Score Display - Out of 10
                VStack(spacing: 6) {
                    Text("YOU SCORED")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .tracking(1.2)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("8.6")
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("/ 10")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.textSecondaryDark)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 28)
                
                // Instructions Subtitle
                Text("Tap words you want Beat Buddy to revisit")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                
                // Action Row: Counter + Select all & Deselect all
                HStack {
                    Text("\(selectedWords.count) selected")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                    
                    Spacer()
                    
                    Button("Select all") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedWords = Set(wordsList)
                        }
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.primaryBlue)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(StamerleeTheme.textSecondaryDark.opacity(0.4))
                        .padding(.horizontal, 4)
                    
                    Button("Deselect all") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedWords.removeAll()
                        }
                    }
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
                
                // 2-Column Word Grid (Initial Preview)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(Array(wordsList.prefix(6)), id: \.self) { word in
                        let isSelected = selectedWords.contains(word)
                        wordButton(word: word, isSelected: isSelected) {
                            toggleWordSelection(word)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Hyperlink-style "View more" button
                Button {
                    showAllWordsSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("View more")
                            .underline()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                    .foregroundColor(StamerleeTheme.primaryBlue)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 14)
                
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
        .onAppear {
            selectedWords = Set(wordsList.prefix(2))
        }
        .sheet(isPresented: $showAllWordsSheet) {
            wordsSheetView
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(StamerleeTheme.backgroundDark)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Navigation Sheet with Scrollable Word List
    private var wordsSheetView: some View {
        NavigationStack {
            ZStack {
                StamerleeTheme.backgroundDark
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header counter and Select All / Deselect All
                        HStack {
                            Text("\(selectedWords.count) of \(wordsList.count) selected")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(StamerleeTheme.textSecondaryDark)
                            
                            Spacer()
                            
                            Button("Select all") {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedWords = Set(wordsList)
                                }
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.primaryBlue)
                            
                            Text("•")
                                .font(.system(size: 12))
                                .foregroundColor(StamerleeTheme.textSecondaryDark.opacity(0.4))
                                .padding(.horizontal, 4)
                            
                            Button("Deselect all") {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedWords.removeAll()
                                }
                            }
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.textSecondaryDark)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        // 2-Column Word Grid in the exact same UI
                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(wordsList, id: \.self) { word in
                                let isSelected = selectedWords.contains(word)
                                wordButton(word: word, isSelected: isSelected) {
                                    toggleWordSelection(word)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Practice Words")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(StamerleeTheme.backgroundDark, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showAllWordsSheet = false
                    }
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.primaryBlue)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func toggleWordSelection(_ word: String) {
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
