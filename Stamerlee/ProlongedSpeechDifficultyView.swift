import SwiftUI

// MARK: - Prolonged Speech Difficulty View (Screenshot 4: "pro speech screen")
/// Difficulty selection screen for Prolonged Speech exercises (Easy, Medium, Hard).
public struct ProlongedSpeechDifficultyView: View {
    @Bindable public var state: AppState
    
    @State private var showPracticeSheet: Bool = false
    @State private var showLockedAlert: Bool = false
    @State private var lockedAlertText: String = ""
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Navigation Bar
                HStack {
                    BackNavButton {
                        state.navigate(to: .prolongedSpeechIntro, forward: false)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Headings
                VStack(alignment: .leading, spacing: 10) {
                    Text("Prolonged Speech")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                    
                    Text("Practice stretching sounds for smoother,more fluent speech.")
                        .font(.system(size: 14.5, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 36)
                
                // Difficulty Level Cards
                VStack(spacing: 16) {
                    // 1. Easy (UNLOCKED)
                    difficultyCard(
                        title: "Easy",
                        isLocked: false
                    ) {
                        state.selectedDifficulty = "Easy"
                        state.navigate(to: .prolongedPractice)
                    }
                    
                    // 2. Medium (LOCKED)
                    difficultyCard(
                        title: "Medium",
                        isLocked: true
                    ) {
                        lockedAlertText = "Complete 3 Easy practice sessions to unlock Medium difficulty."
                        showLockedAlert = true
                    }
                    
                    // 3. Hard (LOCKED)
                    difficultyCard(
                        title: "Hard",
                        isLocked: true
                    ) {
                        locke
                        dAlertText = "Complete Medium practice sessions to unlock Hard difficulty."
                        showLockedAlert = true
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showPracticeSheet) {
            EasyPracticeSessionSheet(state: state)
        }
        .alert("Level Locked", isPresented: $showLockedAlert) {
            Button("Got it", role: .cancel) {}
        } message: {
            Text(lockedAlertText)
        }
    }
    
    // MARK: - Difficulty Card
    private func difficultyCard(
        title: String,
        isLocked: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: isLocked ? .light : .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack {
                if isLocked {
                    // Blue Lock Badge
                    ZStack {
                        Circle()
                            .fill(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 8)
                    
                    Spacer()
                    
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryLight)
                    
                    Spacer()
                } else {
                    Spacer()
                    
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryLight)
                    
                    Spacer()
                }
                
                // Trailing Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.trailing, 8)
            }
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Interactive Easy Practice Session Sheet
private struct EasyPracticeSessionSheet: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentWordIndex: Int = 0
    @State private var isRecording: Bool = false
    @State private var timerSeconds: Int = 0
    @State private var timer: Timer? = nil
    
    private let targetWords = [
        ("Waaater", "waa • ter", "Stretch the initial 'W' and glide smoothly"),
        ("Ssssun", "ssss • un", "Continuous airflow through the 'S' sound"),
        ("Mmmorning", "mmm • orning", "Resonate gentle vibration on 'M'"),
        ("Ppplease", "ppp • lease", "Soft light contact without hard blocking")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                StamerleeTheme.backgroundDark
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Progress Indicator
                    HStack(spacing: 6) {
                        ForEach(0..<targetWords.count, id: \.self) { i in
                            Capsule()
                                .fill(i <= currentWordIndex ? StamerleeTheme.primaryBlue : Color.white.opacity(0.2))
                                .frame(height: 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Practice Word Card
                    VStack(spacing: 12) {
                        Text("WORD \(currentWordIndex + 1) OF \(targetWords.count)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.accentPurpleLight)
                            .tracking(1)
                        
                        Text(targetWords[currentWordIndex].0)
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(targetWords[currentWordIndex].1)
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(red: 200 / 255, green: 210 / 255, blue: 255 / 255))
                        
                        Text(targetWords[currentWordIndex].2)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(StamerleeTheme.textSecondaryDark)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 28)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .padding(.horizontal, 24)
                    
                    // Audio Waveform Visualization
                    if isRecording {
                        HStack(spacing: 4) {
                            ForEach(0..<12) { i in
                                Capsule()
                                    .fill(StamerleeTheme.primaryBlue)
                                    .frame(width: 4, height: CGFloat.random(in: 12...44))
                                    .animation(.easeInOut(duration: 0.25).repeatForever(), value: isRecording)
                            }
                        }
                        .frame(height: 50)
                    } else {
                        Text("Hold or tap to stretch speech")
                            .font(.system(size: 13))
                            .foregroundColor(StamerleeTheme.textSecondaryDark)
                            .frame(height: 50)
                    }
                    
                    Spacer()
                    
                    // Microphone Action Button
                    Button(action: {
                        toggleRecording()
                    }) {
                        ZStack {
                            Circle()
                                .fill(isRecording ? Color.red : StamerleeTheme.primaryBlue)
                                .frame(width: 76, height: 76)
                                .shadow(color: (isRecording ? Color.red : StamerleeTheme.primaryBlue).opacity(0.4), radius: 14, x: 0, y: 6)
                            
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Next Word / Complete Button
                    Button(action: {
                        if currentWordIndex < targetWords.count - 1 {
                            currentWordIndex += 1
                            stopRecording()
                        } else {
                            dismiss()
                        }
                    }) {
                        Text(currentWordIndex < targetWords.count - 1 ? "Next Word" : "Complete Exercise")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Prolonged Speech: Easy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        stopRecording()
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        isRecording = true
        timerSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timerSeconds += 1
        }
    }
    
    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
    }
}
