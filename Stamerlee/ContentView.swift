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
                    LaunchView(state: appState)
                        .transition(.opacity)
                case .onboarding1, .onboarding2, .dailyGoal, .exploreActivities:
                    OnboardingFlowView(state: appState)
                        .transition(.opacity)
                case .homeDashboard:
                    DashboardTabView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .profile:
                    ProfileView(state: appState)
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
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.98)),
                                removal: .opacity
                            )
                        )
                case .pictureDescriptionIntro:
                    PictureDescriptionIntroView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .pictureDescriptionDifficulty, .pictureDescriptionPractice:
                    PictureDescriptionEasyView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .dialSceneIntro:
                    DialSceneIntroView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .dialScene:
                    DialSceneView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .narrationIntro:
                    NarrationIntroView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .narrationDifficulty, .narrationPractice:
                    NarrationPracticeView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .beatBuddyWords:
                    BeatBuddyWordsView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .beatBuddyBPM:
                    BeatBuddyBPMView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .beatBuddyPractice:
                    BeatBuddyPracticeView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                }
            }
            .animation(.easeInOut(duration: 0.24), value: appState.currentScreen)
            
            // Quick Screen Navigation Pill (for easy previewing & testing)
            if showScreenPicker {
                screenPickerOverlay
            }
        }
        .preferredColorScheme(.dark)
        .sheet(
            isPresented: Binding(
                get: { appState.currentScreen == .login },
                set: { isPresented in
                    if !isPresented && appState.currentScreen == .login {
                        appState.navigate(to: .launch, forward: false)
                    }
                }
            )
        ) {
            NavigationStack {
                LoginView(state: appState)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
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
                    .foregroundStyle(.white.opacity(0.8))
                
                Spacer()
                
                Button(action: {
                    withAnimation { showScreenPicker = false }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    jumpButton(title: "Launch", screen: .launch)
                    jumpButton(title: "Login", screen: .login)
                    jumpButton(title: "Info 1", screen: .onboarding1)
                    jumpButton(title: "Info 2", screen: .onboarding2)
                    jumpButton(title: "Daily Goal", screen: .dailyGoal)
                    jumpButton(title: "Explore", screen: .exploreActivities)
                    jumpButton(title: "Home", screen: .homeDashboard)
                    jumpButton(title: "Pro Speech", screen: .prolongedSpeechIntro)
                    jumpButton(title: "Pic Intro", screen: .pictureDescriptionIntro)
                    jumpButton(title: "Dial Intro", screen: .dialSceneIntro)
                    jumpButton(title: "Narr Intro", screen: .narrationIntro)
                    jumpButton(title: "Dial Scene", screen: .dialScene)
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
                .foregroundStyle(appState.currentScreen == screen ? .white : .white.opacity(0.7))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(appState.currentScreen == screen ? StamerleeTheme.primaryBlue : Color.white.opacity(0.12))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Stack-based Onboarding Flow
private struct OnboardingFlowView: View {
    @Bindable var state: AppState
    @State private var path: [AppScreen] = []

    private let pages: [AppScreen] = [
        .onboarding1,
        .onboarding2,
        .dailyGoal,
        .exploreActivities
    ]

    var body: some View {
        NavigationStack(path: $path) {
            OnboardingStepOneView(state: state)
                .navigationDestination(for: AppScreen.self) { screen in
                    destinationView(for: screen)
                }
                .toolbar(.visible, for: .navigationBar)
                .toolbarBackground(StamerleeTheme.backgroundDark, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
        }
        .animation(.easeInOut(duration: 0.28), value: state.currentScreen)
        .onAppear {
            syncPath(with: state.currentScreen)
        }
        .onChange(of: state.currentScreen) { _, newScreen in
            syncPath(with: newScreen)
        }
        .onChange(of: path) { _, newPath in
            guard let screen = newPath.last ?? pages.first,
                  screen != state.currentScreen else {
                return
            }

            let currentIndex = pages.firstIndex(of: state.currentScreen) ?? 0
            let newIndex = pages.firstIndex(of: screen) ?? currentIndex
            state.navigate(to: screen, forward: newIndex >= currentIndex)
        }
    }

    @ViewBuilder
    private func destinationView(for screen: AppScreen) -> some View {
        switch screen {
        case .onboarding2:
            OnboardingStepTwoView(state: state)
        case .dailyGoal:
            DailyGoalView(state: state)
        case .exploreActivities:
            ExploreActivitiesView(state: state)
        default:
            EmptyView()
        }
    }

    private func syncPath(with screen: AppScreen) {
        guard let index = pages.firstIndex(of: screen) else {
            return
        }
        let expectedPath = Array(pages.dropFirst().prefix(index))
        if path != expectedPath {
            path = expectedPath
        }
    }
}

#Preview {
    ContentView()
}
