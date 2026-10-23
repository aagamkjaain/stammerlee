import SwiftUI

// MARK: - Home Dashboard View (Screenshot 2: "Welcome")
/// Main application hub with daily goals, exercise modules, and bottom tab bar.
public struct HomeDashboardView: View {
    @Bindable public var state: AppState
    
    @State private var showLockedAlert: Bool = false
    @State private var lockedAlertMessage: String = ""
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            if state.selectedTab == 0 {
                VStack(alignment: .leading, spacing: 0) {
                // Header Bar
                HStack {
                    Text("Welcome")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                    
                    Spacer()
                    
                    // Replay Onboarding Button
                    Button(action: {
                        state.navigate(to: .exploreActivities, forward: false)
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(8)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 14)
                
                // Scrollable Body Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Daily Goal Banner Card
                        dailyGoalCard
                        
                        // Exercises Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercises")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(StamerleeTheme.textPrimaryDark)
                            
                            // 1. Prolonged Speech (UNLOCKED - Primary action)
                            exerciseRow(
                                title: "Prolonged Speech",
                                subtitle: "Practice gently stretching sounds while speaking slowly.",
                                isLocked: false,
                                iconName: "IconProlongedSpeech",
                                fallbackPath: "/Users/user89/Documents/bitch/Screenshot_2026-10-21_at_11.26.10_PM-removebg-preview 2.png"
                            ) {
                                state.navigate(
                                    to: state.hasSeenProlongedSpeechIntro
                                        ? .prolongedSpeechDifficulty
                                        : .prolongedSpeechIntro
                                )
                            }
                            
                            // 2. Picture Description (unlocked after Prolonged Speech Hard)
                            exerciseRow(
                                title: "Picture Description",
                                subtitle: "Describe what you see using simple words",
                                isLocked: !state.isPictureDescriptionUnlocked,
                                iconName: "IconPictureDesc",
                                fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/IconPictureDesc.png"
                            ) {
                                if state.isPictureDescriptionUnlocked {
                                    state.navigate(to: .pictureDescriptionDifficulty)
                                } else {
                                    triggerLockedAlert(title: "Picture Description")
                                }
                            }
                            
                            // 3. Dial Scene (unlocked after Picture Description Hard)
                            exerciseRow(
                                title: "Dial Scene",
                                subtitle: "Practice speaking through everyday conversations.",
                                isLocked: !state.isDialSceneUnlocked,
                                iconName: "IconDialScene",
                                fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/IconDialScene.png"
                            ) {
                                if state.isDialSceneUnlocked {
                                    state.navigate(to: .dialScene)
                                } else {
                                    triggerLockedAlert(title: "Dial Scene")
                                }
                            }
                            
                            // 4. Narration (unlocked after one completed Dial Scene)
                            exerciseRow(
                                title: "Narration",
                                subtitle: "Narrate a story one sentence at a time.",
                                isLocked: !state.isNarrationUnlocked,
                                iconName: "IconMirrorNarration",
                                fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/IconMirrorNarration.png"
                            ) {
                                if state.isNarrationUnlocked {
                                    state.navigate(to: .narrationDifficulty)
                                } else {
                                    triggerLockedAlert(title: "Narration")
                                }
                            }
                        }
                        
                        // Practice Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Practice")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(StamerleeTheme.textPrimaryDark)
                            
                            // Beat Buddy (unlocked after Prolonged Speech Easy)
                            exerciseRow(
                                title: "Beat Buddy",
                                subtitle: "Narrate a story one sentence at a time.",
                                isLocked: !state.isBeatBuddyUnlocked,
                                iconName: "BeatBuddyLogo",
                                fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/IconMirrorNarration.png"
                            ) {
                                if !state.isBeatBuddyUnlocked {
                                    triggerLockedAlert(title: "Beat Buddy")
                                }
                            }
                        }
                        
                        // Extra bottom padding for floating tab bar
                        Spacer().frame(height: 90)
                    }
                    .padding(.horizontal, 20)
                }
                }
            } else {
                Color.white
                    .ignoresSafeArea()
            }
            
            nativeTabBar
        }
        .alert("Module Locked", isPresented: $showLockedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(lockedAlertMessage)
        }
    }
    
    // MARK: - Daily Goal Card
    private var dailyGoalCard: some View {
        HStack(spacing: 14) {
            // Clock Illustration Asset
            Group {
                if let uiImage = StamerleeImageLoader.loadHeroImage(name: "ClockIllustration", fallbackPath: "/Users/user89/Documents/bitch/clock illustration.png") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 68, height: 68)
                } else {
                    Circle()
                        .fill(Color(red: 254 / 255, green: 220 / 255, blue: 90 / 255))
                        .frame(width: 58, height: 58)
                        .overlay(
                            Image(systemName: "clock.badge.checkmark")
                                .font(.system(size: 26))
                                .foregroundColor(.black)
                        )
                }
            }
            .frame(width: 72, height: 72)
            
            // Goal Text Details
            VStack(alignment: .leading, spacing: 3) {
                Text("YOUR DAILY GOAL")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryLight)
                    .tracking(0.6)
                
                Text("Practice for 10 minutes")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryLight)
                
                Text("Small steps build big progress.")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryLight)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Exercise List Row
    private func exerciseRow(
        title: String,
        subtitle: String,
        isLocked: Bool,
        iconName: String? = nil,
        fallbackPath: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        return Button(action: {
            let impact = UIImpactFeedbackGenerator(style: isLocked ? .light : .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 14) {
                // Leading Icon
                if isLocked {
                    // Blue Lock Circle
                    ZStack {
                        Circle()
                            .fill(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))
                            .frame(width: 40, height: 50)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    // Every unlocked exercise uses the same fixed icon treatment.
                    if let iconName, let fallbackPath,
                       let uiImage = StamerleeImageLoader.loadHeroImage(name: iconName, fallbackPath: fallbackPath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 75, height: 75)
                    } else {
                        Image(systemName: "waveform.and.mic")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(StamerleeTheme.primaryBlue)
                            .frame(width: 75, height: 75)
                    }
                }
                
                // Title and Subtitle
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryLight)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryLight)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Trailing Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Native Tab Bar
    private var nativeTabBar: some View {
        TabView(selection: Binding(
            get: { state.selectedTab },
            set: { newValue in
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                withAnimation(.easeInOut(duration: 0.22)) {
                    state.selectedTab = newValue
                }
            }
        )) {
            Color.clear
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            Color.clear
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.xaxis")
                }
                .tag(1)

            Color.clear
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(2)
        }
        .frame(height: 70)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
    
    private func triggerLockedAlert(title: String) {
        lockedAlertMessage = "\(title) will unlock as you complete the Prolonged Speech foundation exercises!"
        showLockedAlert = true
    }
}
