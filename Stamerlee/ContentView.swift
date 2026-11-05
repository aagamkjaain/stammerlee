import SwiftUI

enum ProfileAvatarSlot {
    case home
    case profile
}

private struct ProfileAvatarFrameReporterKey: EnvironmentKey {
    static let defaultValue: ((ProfileAvatarSlot, CGRect) -> Void)? = nil
}

extension EnvironmentValues {
    var profileAvatarFrameReporter: ((ProfileAvatarSlot, CGRect) -> Void)? {
        get { self[ProfileAvatarFrameReporterKey.self] }
        set { self[ProfileAvatarFrameReporterKey.self] = newValue }
    }
}

// MARK: - Root Content View
/// Master container managing transitions across all onboarding, exploration, and practice screens.
public struct ContentView: View {
    @State private var appState = AppState()
    @State private var showScreenPicker: Bool = false
    @State private var homeAvatarFrame: CGRect = .zero
    @State private var profileAvatarFrame: CGRect = .zero
    @State private var floatingAvatarFrame: CGRect = .zero
    @State private var showFloatingAvatar = false
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Active Screen with directional transition
            Group {
                switch appState.currentScreen {
                case .launch:
                    LaunchView(state: appState)
                        .transition(
                            .asymmetric(
                                insertion: .opacity,
                                removal: .opacity.combined(with: .scale(scale: 1.04))
                            )
                        )
                case .login:
                    LoginView(state: appState)
                        .transition(
                            .asymmetric(
                                insertion: .opacity,
                                removal: slideTransition(for: appState.navigationDirection)
                            )
                        )
                case .onboarding1:
                    OnboardingStepOneView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .onboarding2:
                    OnboardingStepTwoView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .dailyGoal:
                    DailyGoalView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .exploreActivities:
                    ExploreActivitiesView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .homeDashboard, .profile:
                    DashboardTabView(state: appState)
                        .zIndex(1)
                        .transition(.identity)
                case .fluencyLap:
                    FluencyLapView(state: appState)
                        .transition(slideTransition(for: appState.navigationDirection))
                case .fluencyLapPractice:
                    FluencyLapPracticeView(state: appState)
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
                case .beatBuddyPracticeType:
                    BeatBuddyWordsView(state: appState)
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
            .animation(
                appState.isProfileTransition
                    ? .spring(response: 0.44, dampingFraction: 0.82)
                    : .spring(response: 0.45, dampingFraction: 0.88),
                value: appState.currentScreen
            )
            
            // Quick Screen Navigation Pill (for easy previewing & testing)
            if showScreenPicker {
                screenPickerOverlay
            }

            if appState.currentScreen == .profile {
                ProfileView(state: appState)
                    .zIndex(2)
            }

            if showFloatingAvatar, floatingAvatarFrame != .zero {
                GeometryReader { proxy in
                    ProfileAvatar(
                        style: appState.profileAvatarStyle,
                        imageData: appState.profileAvatarData,
                        size: floatingAvatarFrame.width
                    )
                    .frame(
                        width: floatingAvatarFrame.width,
                        height: floatingAvatarFrame.height
                    )
                    .position(
                        x: floatingAvatarFrame.midX - proxy.frame(in: .global).minX,
                        y: floatingAvatarFrame.midY - proxy.frame(in: .global).minY
                    )
                    .allowsHitTesting(false)
                }
                .zIndex(10)
            }
        }
        .environment(\.profileAvatarFrameReporter) { slot, frame in
            switch slot {
            case .home:
                homeAvatarFrame = frame
            case .profile:
                profileAvatarFrame = frame
            }
        }
        .preferredColorScheme(.dark)
        // Two finger tap anywhere to toggle the quick screen jump bar
        .onTapGesture(count: 2) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                showScreenPicker.toggle()
            }
        }
        .onChange(of: appState.currentScreen) { oldScreen, newScreen in
            guard oldScreen != newScreen else { return }

            if newScreen == .profile {
                showFloatingAvatar = true
                floatingAvatarFrame = homeAvatarFrame
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.52, dampingFraction: 0.82)) {
                        floatingAvatarFrame = profileAvatarFrame
                    }
                }
            } else if oldScreen == .profile {
                showFloatingAvatar = true
                floatingAvatarFrame = profileAvatarFrame
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.48, dampingFraction: 0.84)) {
                        floatingAvatarFrame = homeAvatarFrame
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showFloatingAvatar = false
                    }
                }
            }
        }
    }
    
    // MARK: - Directional Slide with Depth Transition
    private func slideTransition(for edge: Edge) -> AnyTransition {
        let oppositeEdge: Edge = (edge == .trailing ? .leading : .trailing)
        return .asymmetric(
            insertion: .move(edge: edge)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.96)),
            removal: .move(edge: oppositeEdge)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.96))
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

#Preview {
    ContentView()
}
