import SwiftUI
import UIKit

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
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    
                    Spacer()

                    Button {
                        state.navigate(to: .profile)
                    } label: {
                        ProfileAvatar(
                            style: state.profileAvatarStyle,
                            imageData: state.profileAvatarData,
                            size: 38
                        )
                    }
                    .accessibilityLabel("Open profile")
                    
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 14)
                
                // Scrollable Body Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Daily Challenge Card
                        dailyChallengeCard
                        
                        // Exercises Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercises")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryDark)
                            
                            // 1. Prolonged Speech (UNLOCKED - Primary action)
                            exerciseRow(
                                title: "Prolonged Speech",
                                subtitle: "Practice gently stretching sounds while speaking slowly",
                                isLocked: false,
                                iconName: "IconProlongedSpeech",
                                fallbackPath: "/Users/user89/Documents/stammerlee/Screenshot_2026-10-21_at_11.26.10_PM-removebg-preview 2.png"
                            ) {
                                state.navigate(
                                    to: state.hasSeenProlongedSpeechIntro
                                        ? .prolongedSpeechDifficulty
                                        : .prolongedSpeechIntro
                                )
                            }
                            
                            // 2. Picture Description
                            exerciseRow(
                                title: "Picture Description",
                                subtitle: "Describe real-world scenes in detail to practice spontaneous speech flow",
                                isLocked: false,
                                iconName: "IconPictureDesc",
                                fallbackPath: "/Users/user89/Documents/stammerlee/Stamerlee/IconPictureDesc.png"
                            ) {
                                state.navigate(
                                    to: state.hasSeenPictureDescriptionIntro
                                        ? .pictureDescriptionPractice
                                        : .pictureDescriptionIntro
                                )
                            }
                            
                            // 3. Dial Scene
                            exerciseRow(
                                title: "Dial Scene",
                                subtitle: "Practice interactive scenario-based phone calls and service counter chats",
                                isLocked: false,
                                iconName: "IconDialScene",
                                fallbackPath: "/Users/user89/Documents/stammerlee/Stamerlee/IconDialScene.png"
                            ) {
                                state.navigate(
                                    to: state.hasSeenDialSceneIntro
                                        ? .dialScene
                                        : .dialSceneIntro
                                )
                            }
                            
                            // 4. Narration
                            exerciseRow(
                                title: "Narration",
                                subtitle: "Practice reading and telling longer stories while watching yourself in the mirror",
                                isLocked: false,
                                iconName: "IconMirrorNarration",
                                fallbackPath: "/Users/user89/Documents/stammerlee/Stamerlee/IconMirrorNarration.png"
                            ) {
                                state.navigate(
                                    to: state.hasSeenNarrationIntro
                                        ? .narrationPractice
                                        : .narrationIntro
                                )
                            }
                        }
                        
                        // Practice Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Practice")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryDark)
                            
                            // Beat Buddy
                            exerciseRow(
                                title: "Beat Buddy",
                                subtitle: "Practice speaking to a steady, rhythmic beat using an interactive metronome",
                                isLocked: false,
                                iconName: "BeatBuddyLogo",
                                fallbackPath: "/Users/user89/Documents/stammerlee/Stamerlee/IconMirrorNarration.png"
                            ) {
                                state.navigate(to: .beatBuddyWords)
                            }
                        }
                        
                        // Extra bottom padding for floating tab bar
                        Spacer().frame(height: 90)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }

        .alert("Module Locked", isPresented: $showLockedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(lockedAlertMessage)
        }
    }
    
    // MARK: - Daily Challenge Card
    private var dailyChallengeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily\nChallenge")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 20 / 255, green: 22 / 255, blue: 35 / 255))
                        .lineSpacing(-2)

                    Text("A short, focused practice session to build fluency and confidence in your speech.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 14)

                // Calendar illustration with soft backdrop blob
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(red: 226 / 255, green: 224 / 255, blue: 252 / 255).opacity(0.85))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(7))

                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(StamerleeTheme.primaryPurple)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                }
                .frame(width: 72, height: 72)
            }

            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                state.navigate(to: .beatBuddyWords)
            }) {
                HStack(spacing: 8) {
                    Text("Start Challenge")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color(red: 35 / 255, green: 37 / 255, blue: 62 / 255))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(
            Color(red: 242 / 255, green: 243 / 255, blue: 252 / 255),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 7, x: 0, y: 3)
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
                            .foregroundStyle(.white)
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
                        .foregroundStyle(StamerleeTheme.textPrimaryLight)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Trailing Chevron
                if !isLocked {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.gray.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 100)
            .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func triggerLockedAlert(title: String) {
        if title == "Beat Buddy" {
            lockedAlertMessage = "Complete Prolonged Speech Easy and receive a score to unlock Beat Buddy!"
        } else {
            lockedAlertMessage = "\(title) will unlock as you complete the Prolonged Speech foundation exercises!"
        }
        showLockedAlert = true
    }
}






public struct DashboardTabView: View {
    @Bindable public var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        TabView(selection: state.selectedTabBinding) {
            HomeDashboardView(state: state)
                .tabItem {
                    Label(
                        AppTab.home.title,
                        systemImage: AppTab.home.systemImage
                    )
                }
                .tag(AppTab.home)

            SummaryView(state: state)
                .tabItem {
                    Label(
                        AppTab.summary.title,
                        systemImage: AppTab.summary.systemImage
                    )
                }
                .tag(AppTab.summary)
        }
        .tint(StamerleeTheme.primaryBlue)
        .toolbarBackground(
            StamerleeTheme.backgroundDark,
            for: .tabBar
        )
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .preferredColorScheme(.dark)
    }
}
