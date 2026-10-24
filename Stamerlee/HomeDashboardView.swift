import SwiftUI
import UIKit

// MARK: - Home Dashboard View (Screenshot 2: "Welcome")
/// Main application hub with daily goals, exercise modules, and bottom tab bar.
public struct HomeDashboardView: View {
    @Bindable public var state: AppState
    private let showsTabBar: Bool
    
    @State private var showLockedAlert: Bool = false
    @State private var lockedAlertMessage: String = ""
    
    public init(state: AppState, showsTabBar: Bool = true) {
        self.state = state
        self.showsTabBar = showsTabBar
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
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                    
                    Spacer()

                    Button {
                        state.navigate(to: .profile)
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(StamerleeTheme.textPrimaryDark)
                    }
                    .accessibilityLabel("Open profile")
                    
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
                                subtitle: "Practice gently stretching sounds while speaking slowly",
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
                                subtitle: "Describe real-world scenes in detail to practice spontaneous speech flow",
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
                                subtitle: "Practice interactive scenario-based phone calls and service counter chats",
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
                                subtitle: "Practice reading and telling longer stories while watching yourself in the mirror",
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
                                subtitle: "Practice speaking to a steady, rhythmic beat using an interactive metronome",
                                isLocked: !state.isBeatBuddyUnlocked,
                                iconName: "BeatBuddyLogo",
                                fallbackPath: "/Users/user89/Documents/bitch/Stamerlee/IconMirrorNarration.png"
                            ) {
                                if state.isBeatBuddyUnlocked {
                                    state.navigate(to: .beatBuddyWords)
                                } else {
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
            
            if showsTabBar {
                nativeTabView
            }
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
            DailyGoalActivityRing()

            VStack(alignment: .leading, spacing: 3) {
                Text("YOUR DAILY GOAL")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryLight)
                    .tracking(1.2)
                
                Text("Practice for \(state.dailyPracticeMinutes) minutes")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryLight)
                
                Text("Your daily fluency goal.")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryLight)
            }
            
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.white)
                    }.frame(width:75, height:75)
                } else {
                    // Every unlocked exercise uses the same fixed icon treatment.
                    if let iconName, let fallbackPath,
                       let uiImage = StamerleeImageLoader.loadHeroImage(name: iconName, fallbackPath: fallbackPath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
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
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Trailing Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .frame(height: 100)
            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Native Tab Bar
    @ViewBuilder
    private var nativeTabView: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: tabSelectionBinding) {
                Tab("Home", systemImage: "house.fill", value: 0) {
                    Color.clear
                }
                Tab("Summary", systemImage: "chart.bar.fill", value: 1) {
                    Color.clear
                }
            }
        } else {
            TabView(selection: tabSelectionBinding) {
                Color.clear
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)
                Color.clear
                    .tabItem { Label("Summary", systemImage: "chart.bar.fill") }
                    .tag(1)
            }
        }
    }

    private var tabSelectionBinding: Binding<Int> {
        Binding(
            get: { state.selectedTab },
            set: { newValue in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.easeInOut(duration: 0.22)) {
                    state.selectedTab = newValue
                }
            }
        )
    }
    
    private func triggerLockedAlert(title: String) {
        lockedAlertMessage = "\(title) will unlock as you complete the Prolonged Speech foundation exercises!"
        showLockedAlert = true
    }
}


private struct DailyGoalActivityRing: View {
    private let ringSize: CGFloat = 63
    private let lineWidth: CGFloat = 10
    private let progress: Double = 0.25

    @State private var animatedProgress: Double = 0

    private let trackColor = Color(red: 74.0 / 255.0, green: 57.0 / 255.0, blue: 123.0 / 255.0)

    private let progressColor = Color(red: 139.0 / 255.0, green: 112.0 / 255.0, blue: 245.0 / 255.0)

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            // Inner circle
            Circle()
                .fill(StamerleeTheme.profileCard)
                .padding(lineWidth)
        }
        .frame(width: ringSize, height: ringSize)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = min(max(progress, 0), 1)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily goal progress")
        .accessibilityValue(
            "\(Int(progress * 100)) percent"
        )
    }
}



public struct DashboardTabView: View {
    @Bindable public var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        TabView(selection: tabSelectionBinding) {
            HomeDashboardView(state: state, showsTabBar: false)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            SummaryView(state: state)
                .tabItem {
                    Label("Summary", systemImage: "chart.bar.fill")
                }
                .tag(1)

        }
    }

    private var tabSelectionBinding: Binding<Int> {
        Binding(
            get: { state.selectedTab },
            set: { newValue in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation(.easeInOut(duration: 0.22)) {
                    state.selectedTab = newValue
                }
            }
        )
    }
}
