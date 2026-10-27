import SwiftUI

// MARK: - Prolonged Speech Intro View (Screenshot 3: "prolonged speech")
/// Introduces the Prolonged Speech stretch and smoothing technique.
public struct ProlongedSpeechIntroView: View {
    @Bindable public var state: AppState
    
    @State private var breatheEffect: Bool = false
    
    private let heroFallbackPath = "/Users/user89/Documents/stammerlee/Screenshot 2026-10-22 at 3.16.37 PM 1.png"
    
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
                        state.navigate(to: .homeDashboard, forward: false)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Headings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Let's start with\nProlonged Speech")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .lineSpacing(2)
                    
                    Text("Learn to gently stretch sounds and connect words smoothly. This technique can help reduce speech tension and improve fluency with practice")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)
                
                Spacer()
                
                // Hero Illustration from uploaded screenshot
                ZStack {
                    if let uiImage = StamerleeImageLoader.loadHeroImage(name: "ProlongedSpeechHero", fallbackPath: heroFallbackPath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 280)
                            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
                            .scaleEffect(breatheEffect ? 1.015 : 0.985)
                            .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: breatheEffect)
                    } else {
                        // Fallback
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 25 / 255, green: 30 / 255, blue: 65 / 255))
                            .frame(width: 250, height: 230)
                            .overlay(
                                Image(systemName: "waveform.and.mic")
                                    .font(.system(size: 60))
                                    .foregroundColor(StamerleeTheme.primaryBlue)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                
                Spacer()
                
                // Bottom CTA Button ("Continue")
                VStack {
                    PrimaryActionButton(title: "Continue") {
                        state.hasSeenProlongedSpeechIntro = true
                        state.navigate(to: .prolongedSpeechDifficulty)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            breatheEffect = true
        }
    }
}
