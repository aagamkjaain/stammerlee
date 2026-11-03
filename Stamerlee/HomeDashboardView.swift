import SwiftUI
import UIKit

// MARK: - Home Dashboard View (Screenshot 2: "Welcome")
/// Main application hub with daily goals, exercise modules, and bottom tab bar.
public struct HomeDashboardView: View {
    @Bindable public var state: AppState
    public var profileNamespace: Namespace.ID? = nil
    
    @State private var showLockedAlert: Bool = false
    @State private var lockedAlertMessage: String = ""
    @State private var cardsAppeared: Bool = false
    
    public init(state: AppState, profileNamespace: Namespace.ID? = nil) {
        self.state = state
        self.profileNamespace = profileNamespace
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
                        .matchedGeometryEffectIfPresent(id: "profileAvatarHero", in: profileNamespace)
                    }
                    .buttonStyle(AvatarInteractiveButtonStyle())
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
                            .offset(y: cardsAppeared ? 0 : 36)
                            .scaleEffect(cardsAppeared ? 1.0 : 0.94)
                            .opacity(cardsAppeared ? 1 : 0)
                            .animation(
                                .spring(response: 0.52, dampingFraction: 0.65).delay(0.04),
                                value: cardsAppeared
                            )
                        
                        // Exercises Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercises")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryDark)
                            
                            // 1. Prolonged Speech (UNLOCKED - Primary action)
                            exerciseRow(
                                title: "Prolonged Speech",
                                subtitle: "Practice gently stretching sounds while speaking slowly.",
                                isLocked: false,
                                iconName: "IconProlongedSpeech"
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
                                iconName: "IconPictureDesc"
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
                                iconName: "IconDialScene"
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
                                iconName: "IconMirrorNarration"
                            ) {
                                state.navigate(
                                    to: state.hasSeenNarrationIntro
                                        ? .narrationPractice
                                        : .narrationIntro
                                )
                            }
                        }
                        .offset(y: cardsAppeared ? 0 : 40)
                        .scaleEffect(cardsAppeared ? 1.0 : 0.94)
                        .opacity(cardsAppeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.54, dampingFraction: 0.67).delay(0.08),
                            value: cardsAppeared
                        )
                        
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
                                iconName: "BeatBuddyLogo"
                            ) {
                                state.navigate(to: .beatBuddyPracticeType)
                            }
                        }
                        .offset(y: cardsAppeared ? 0 : 44)
                        .scaleEffect(cardsAppeared ? 1.0 : 0.94)
                        .opacity(cardsAppeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.56, dampingFraction: 0.69).delay(0.12),
                            value: cardsAppeared
                        )
                        
                        // Extra bottom padding for floating tab bar
                        Spacer().frame(height: 90)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            cardsAppeared = false
            withAnimation {
                cardsAppeared = true
            }
        }
        .onChange(of: state.currentScreen) { _, newScreen in
            if newScreen == .homeDashboard {
                cardsAppeared = false
                withAnimation {
                    cardsAppeared = true
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
            HStack(alignment: .center, spacing: 16) {
                // Calendar illustration on the LEFT
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(red: 226 / 255, green: 224 / 255, blue: 252 / 255).opacity(0.85))
                        .frame(width: 68, height: 68)
                        .rotationEffect(.degrees(-5))

                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(StamerleeTheme.primaryPurple)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                }
                .frame(width: 68, height: 68)

                // Title and subtitle on the RIGHT
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Challenge")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 20 / 255, green: 22 / 255, blue: 35 / 255))

                    Text("A short, focused practice session to build fluency and confidence in your speech.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)
                        .lineSpacing(2)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: {
                state.navigate(to: .beatBuddyPracticeType)
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
            .buttonStyle(.haptic)
        }
        .padding(18)
        .background(
            Color(red: 242 / 255, green: 243 / 255, blue: 252 / 255),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 7, x: 0, y: 3)
    }
    
    private func exerciseRow(
        title: String,
        subtitle: String,
        isLocked: Bool,
        iconName: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        ExerciseRowCard(
            title: title,
            subtitle: subtitle,
            isLocked: isLocked,
            iconName: iconName,
            action: action
        )
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

// MARK: - Exercise Row Card
/// Card that keeps the original lavender look but gains the native iOS 26 glass
/// "bumpy" press physics via .buttonStyle(.glass). Falls back to BouncyCardButtonStyle
/// on iOS < 26 so the card colour is always identical.
private struct ExerciseRowCard: View {
    let title: String
    let subtitle: String
    let isLocked: Bool
    let iconName: String?
    let action: () -> Void

    // The original card colour that matches every other card in the app
    private let cardColor = Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255)

    var body: some View {
        if #available(iOS 26.0, *) {
            // Native glass button — .interactive() gives the bumpy spring press
            // .tint(cardColor) preserves the existing lavender look
            Button(action: action) { cardContent }
                .buttonStyle(.glass(.regular.tint(cardColor).interactive()))
                .buttonBorderShape(.roundedRectangle(radius: 16))
                .frame(maxWidth: .infinity)
        } else {
            Button(action: action) { cardContent }
                .buttonStyle(BouncyCardButtonStyle())
                .frame(maxWidth: .infinity)
        }
    }

    private var cardContent: some View {
        HStack(alignment: .center, spacing: 14) {
            // Leading Icon — fixed width so text always starts at the same X
            if isLocked {
                ZStack {
                    Circle()
                        .fill(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))
                        .frame(width: 50, height: 50)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 75, height: 75)
            } else if let iconName {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 75, height: 75)
            }

            // Title + Subtitle — explicitly left-aligned and expanding
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryLight)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Chevron
            if !isLocked {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.gray.opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        // On iOS < 26 draw the card background manually; on iOS 26 the glass style owns rendering
        .background {
            if #available(iOS 26.0, *) {
                Color.clear
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(cardColor)
                    .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            }
        }
    }
}




public struct DashboardTabView: View {
    @Bindable public var state: AppState
    public var profileNamespace: Namespace.ID? = nil

    public init(state: AppState, profileNamespace: Namespace.ID? = nil) {
        self.state = state
        self.profileNamespace = profileNamespace
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch state.selectedTab {
                case .home:
                    HomeDashboardView(state: state, profileNamespace: profileNamespace)
                case .summary:
                    SummaryView(state: state)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            floatingGlassTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.dark)
    }

    // MARK: - Floating Glass Navbar
    private var floatingGlassTabBar: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                let isSelected = state.selectedTab == tab
                Button {
                    state.selectTab(tab)
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        Text(tab.title)
                            .font(.system(size: 11, weight: isSelected ? .semibold : .regular, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(isSelected ? StamerleeTheme.primaryBlue : Color.white.opacity(0.80))
                    .background {
                        if #available(iOS 26.0, *), isSelected {
                            Capsule()
                                .fill(.clear)
                                .glassEffect(.regular.tint(StamerleeTheme.primaryBlue.opacity(0.25)).interactive(), in: .capsule)
                        } else if isSelected {
                            Capsule()
                                .fill(StamerleeTheme.primaryBlue.opacity(0.20))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay {
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.30),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 9)
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
        .sensoryFeedback(.selection, trigger: state.selectedTab)
    }
}
