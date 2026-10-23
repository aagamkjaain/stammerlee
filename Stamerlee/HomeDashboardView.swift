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
                            
                            // 3. Dial Scene (unlocked with Picture Description)
                            exerciseRow(
                                title: "Dial Scene",
                                subtitle: "Practice speaking through everyday conversations.",
                                isLocked: !state.isPictureDescriptionUnlocked,
                                iconName: "IconDialScene",
                                fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/IconDialScene.png"
                            ) {
                                if state.isPictureDescriptionUnlocked {
                                    state.navigate(to: .dialScene)
                                } else {
                                    triggerLockedAlert(title: "Dial Scene")
                                }
                            }
                            
                            // 4. Narration
                            exerciseRow(
                                title: "Narration",
                                subtitle: "Narrate a story one sentence at a time.",
                                isLocked: true,
                                iconName: "IconMirrorNarration",
                                fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/IconMirrorNarration.png"
                            ) {
                                triggerLockedAlert(title: "Narration")
                            }
                        }
                        
                        // Practice Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Practice")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(StamerleeTheme.textPrimaryDark)
                            
                            // Beat Buddy
                            exerciseRow(
                                title: "Beat Buddy",
                                subtitle: "Narrate a story one sentence at a time.",
                                isLocked: true,
                                iconName: "IconMirrorNarration",
                                fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/IconMirrorNarration.png"
                            ) {
                                triggerLockedAlert(title: "Beat Buddy")
                            }
                        }
                        
                        // Extra bottom padding for floating tab bar
                        Spacer().frame(height: 90)
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Bottom Floating Tab Bar
            floatingTabBar
                .padding(.bottom, 16)
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
        Button(action: {
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
    
    // MARK: - Floating Tab Bar
    private var floatingTabBar: some View {
        HStack(spacing: 40) {
            tabItem(title: "Home", icon: "house.fill", index: 0)
            tabItem(title: "Insights", icon: "chart.bar.xaxis", index: 1)
            tabItem(title: "Profile", icon: "person.crop.circle", index: 2)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 10)
        .background(
            Color(red: 25 / 255, green: 30 / 255, blue: 60 / 255).opacity(0.92)
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
    }
    
    private func tabItem(title: String, icon: String, index: Int) -> some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            state.selectedTab = index
        }) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: state.selectedTab == index ? .bold : .medium))
                
                Text(title)
                    .font(.system(size: 10, weight: state.selectedTab == index ? .bold : .regular))
            }
            .foregroundColor(state.selectedTab == index ? .white : Color.gray.opacity(0.7))
        }
    }
    
    private func triggerLockedAlert(title: String) {
        lockedAlertMessage = "\(title) will unlock as you complete the Prolonged Speech foundation exercises!"
        showLockedAlert = true
    }
}
