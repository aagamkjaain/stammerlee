import SwiftUI

// MARK: - Plan Ready Screen
/// Rewarding celebration screen summarizing the user's customized speech plan.
public struct PlanReadyView: View {
    @Bindable public var state: AppState
    
    @State private var appearScale: CGFloat = 0.85
    @State private var appearOpacity: Double = 0.0
    @State private var isPracticing: Bool = false
    @State private var practiceSeconds: Int = 0
    @State private var timer: Timer? = nil
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top navigation bar with Back button
                HStack {
                    BackNavButton {
                        state.navigate(to: .challengingSounds, forward: false)
                    }
                    Spacer()
                    
                    Button("Restart") {
                        state.restartFlow()
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(StamerleeTheme.accentPurpleLight)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Success Badge Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    StamerleeTheme.primaryBlue,
                                    Color(red: 124 / 255, green: 77 / 255, blue: 255 / 255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: StamerleeTheme.primaryBlue.opacity(0.4), radius: 18, x: 0, y: 8)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(appearScale)
                .opacity(appearOpacity)
                
                // Headings
                VStack(spacing: 8) {
                    Text("Your Fluency Plan\nis Ready!")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .multilineTextAlignment(.center)
                    
                    Text("Tailored daily speech activities configured for your selected target sounds.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }
                
                // Summary Card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Target Focus Areas:")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryLight)
                    
                    HStack(spacing: 8) {
                        ForEach(Array(state.selectedSoundIds), id: \.self) { id in
                            let label = SoundOption.sampleOptions.first(where: { $0.id == id })?.title ?? id
                            Text(label)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(StamerleeTheme.primaryBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(StamerleeTheme.primaryBlue.opacity(0.12))
                                .clipShape(Capsule())
                        }
                        
                        if !state.customSoundInput.isEmpty {
                            Text(state.customSoundInput)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(StamerleeTheme.accentPurple)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(StamerleeTheme.accentPurple.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 2)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 22))
                            .foregroundColor(StamerleeTheme.primaryBlue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Daily Pace: 3 - 5 Minutes")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(StamerleeTheme.textPrimaryLight)
                            Text("Gentle phonetic repetitions & rhythmic pacing")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(StamerleeTheme.textSecondaryLight)
                        }
                    }
                }
                .padding(20)
                .background(StamerleeTheme.cardLight)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.horizontal, 24)
                
                // Interactive Mini Practice Simulator
                if isPracticing {
                    HStack(spacing: 14) {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(StamerleeTheme.primaryBlue)
                        
                        Text("Listening & Pacing... \(practiceSeconds)s")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Stop") {
                            stopPractice()
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.red.opacity(0.9))
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    PrimaryActionButton(
                        title: isPracticing ? "Finish Practice" : "Start Today's 3-Min Practice",
                        icon: isPracticing ? "checkmark.circle" : "play.fill"
                    ) {
                        if isPracticing {
                            stopPractice()
                        } else {
                            startPractice()
                        }
                    }
                    
                    Button(action: {
                        state.restartFlow()
                    }) {
                        Text("Return to Welcome")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(StamerleeTheme.textSecondaryDark)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appearScale = 1.0
                appearOpacity = 1.0
            }
        }
        .onDisappear {
            stopPractice()
        }
    }
    
    private func startPractice() {
        isPracticing = true
        practiceSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            practiceSeconds += 1
        }
    }
    
    private func stopPractice() {
        isPracticing = false
        timer?.invalidate()
        timer = nil
    }
}
