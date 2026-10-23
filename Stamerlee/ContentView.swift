import SwiftUI

// MARK: - Root Content View
/// Master container managing transitions across all onboarding, exploration, and practice screens.
public struct ContentView: View {
    @State private var appState = AppState()
    @State private var showScreenPicker: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Active Screen with directional transition
            Group {
                switch appState.currentScreen {
                case .launch:
                    LaunchView(state: appState)
                        .transition(.opacity)
                case .login:
                    LoginView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .onboarding1:
                    OnboardingStepOneView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .onboarding2:
                    OnboardingStepTwoView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .challengingSounds:
                    ChallengingSoundsView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .exploreActivities:
                    ExploreActivitiesView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .homeDashboard:
                    HomeDashboardView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .prolongedSpeechIntro:
                    ProlongedSpeechIntroView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .prolongedSpeechDifficulty:
                    ProlongedSpeechDifficultyView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .prolongedPractice:
                    ProlongedPracticeView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .prolongedAnalysis:
                    ProlongedAnalysisView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .pictureDescriptionDifficulty:
                    PictureDescriptionDifficultyView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .pictureDescriptionPractice:
                    PictureDescriptionEasyView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .dialScene:
                    DialSceneView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: appState.currentScreen)
            
            // Quick Screen Navigation Pill (for easy previewing & testing)
            if showScreenPicker {
                screenPickerOverlay
            }
        }
        .preferredColorScheme(.dark)
        // Two finger tap anywhere to toggle the quick screen jump bar
        .onTapGesture(count: 2) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                showScreenPicker.toggle()
            }
        }
    }
    
    // MARK: - Directional Slide Transition
    private func slideTransition(for edge: Edge) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: edge).combined(with: .opacity),
            removal: .move(edge: edge == .trailing ? .leading : .trailing).combined(with: .opacity)
        )
    }
    
    // MARK: - Quick Screen Jump Bar
    private var screenPickerOverlay: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Screen Jump (Tap to test):")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button(action: {
                    withAnimation { showScreenPicker = false }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    jumpButton(title: "Launch", screen: .launch)
                    jumpButton(title: "Login", screen: .login)
                    jumpButton(title: "Info 1", screen: .onboarding1)
                    jumpButton(title: "Info 2", screen: .onboarding2)
                    jumpButton(title: "Sounds", screen: .challengingSounds)
                    jumpButton(title: "Explore", screen: .exploreActivities)
                    jumpButton(title: "Home", screen: .homeDashboard)
                    jumpButton(title: "Pro Speech", screen: .prolongedSpeechIntro)
                    jumpButton(title: "Difficulty", screen: .prolongedSpeechDifficulty)
                    jumpButton(title: "Practice", screen: .prolongedPractice)
                    jumpButton(title: "Analysis", screen: .prolongedAnalysis)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 48)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private func jumpButton(title: String, screen: AppScreen) -> some View {
        Button(action: {
            appState.navigate(to: screen)
        }) {
            Text(title)
                .font(.system(size: 12, weight: appState.currentScreen == screen ? .bold : .medium))
                .foregroundColor(appState.currentScreen == screen ? .white : .white.opacity(0.7))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(appState.currentScreen == screen ? StamerleeTheme.primaryBlue : Color.white.opacity(0.12))
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ContentView()
}
