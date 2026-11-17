import SwiftUI
import UIKit

// MARK: - Home Dashboard View (Screenshot 2: "Welcome")
/// Main application hub with daily goals, exercise modules, and bottom tab bar.
public struct HomeDashboardView: View {
    @Bindable public var state: AppState
    @Environment(\.headerNamespace) private var headerNamespace
    
    @State private var showLockedAlert: Bool = false
    @State private var lockedAlertMessage: String = ""
    @State private var cardsAppeared: Bool = true
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
       
        ZStack(alignment: .top) {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Header Banner
                headerImageView

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
                        .opacity(state.isHeroAvatarTransitionActive ? 0 : 1)
                        .reportProfileAvatarFrame(.home)
                    }
                    .buttonStyle(AvatarInteractiveButtonStyle())
                    .accessibilityLabel("Open profile")

                }
                .padding(.horizontal, 24)
                .padding(.top, -48)
                .padding(.bottom, 10)

                // Scrollable Body Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Fluency Lap Card
                        fluencyLapCard
                            .offset(y: cardsAppeared ? 0 : 36)
                            .scaleEffect(cardsAppeared ? 1.0 : 0.94)
                            .opacity(cardsAppeared ? 1 : 0)
                            .animation(
                                .spring(response: 0.52, dampingFraction: 0.65).delay(0.04),
                                value: cardsAppeared
                            )
                        
                        // Exercises Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercises")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryDark)
                            
                            // 1. Prolonged Speech (UNLOCKED - Primary action)
                            exerciseRow(
                                title: "Prolonged Speech",
                                subtitle: "Gently stretch sounds while speaking slowly.",
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
                                subtitle: "Practice by describing pictures in detail",
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
                                subtitle: "Mimic speaking in different scenarios through interactive phone calls",
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
                                subtitle: "Speak about different topics infront of the mirror",
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Practice")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(StamerleeTheme.textPrimaryDark)
                            
                            // Beat Buddy
                            exerciseRow(
                                title: "Beat Buddy",
                                subtitle: "Build your pace by speaking at every beat",
                                isLocked: false,
                                iconName: "BeatBuddyLogo"
                            ) {
                                state.navigate(
                                    to: state.hasSeenBeatBuddyIntro
                                        ? .beatBuddyBPM
                                        : .beatBuddyIntro
                                )
                            }
                        }
                        .offset(y: cardsAppeared ? 0 : 44)
                        .scaleEffect(cardsAppeared ? 1.0 : 0.94)
                        .opacity(cardsAppeared ? 1 : 0)
                        .animation(
                            .spring(response: 0.56, dampingFraction: 0.69).delay(0.12),
                            value: cardsAppeared
                        )
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 110)
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            cardsAppeared = true
        }
        .alert("Module Locked", isPresented: $showLockedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(lockedAlertMessage)
        }
    }
    
    // MARK: - Top Header Image
    @ViewBuilder
    private var headerImageView: some View {
        Group {
            if let uiImage = UIImage(named: "header") ?? UIImage(named: "Header") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .top)
            } else {
                Image("Header")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .top)
            }
        }
        .matchedGeometryEffectIfPresent(id: "headerBanner", in: headerNamespace)
    }

    // MARK: - Fluency Lap Card
    private var fluencyLapCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                Group {
                    if let uiImage = UIImage(named: "hey1") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "hey1", ofType: "png") ?? "") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image("hey1")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 76, height: 76)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Challenge")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 20 / 255, green: 22 / 255, blue: 35 / 255))

                    Text("Challenge yourself with a timed session and beat your score")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)
                        .lineSpacing(2)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                if state.hasCompletedFluencyLapIntro {
                    state.fluencyLapWordCount = 20
                    state.navigate(to: .fluencyLapCountdown)
                } else {
                    state.navigate(to: .fluencyLapIntro)
                }
            } label: {
                Text("Start")
                    .font(.system(size: 15.5, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(StamerleeTheme.backgroundDark, in: Capsule())
            }
            .buttonStyle(.popSpring)
        }
        .padding(18)
        .background(Color(red: 238 / 255, green: 240 / 255, blue: 250 / 255), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
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
        Button(action: action) {
            cardContent
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var cardContent: some View {
        HStack(alignment: .center, spacing: 14) {
            // Leading Icon — fixed width so text always starts at the same X
            if isLocked {
                ZStack {
                    Circle()
                        .fill(Color(red: 90 / 255, green: 105 / 255, blue: 180 / 255))
                        .frame(width: 44, height: 44)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 68, height: 68)
            } else if let iconName {
                if iconName == "BeatBuddyLogo" {
                    Image(iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .frame(width: 68, height: 68)
                } else {
                    Image(iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 68, height: 68)
                }
            }

            // Title + Subtitle — explicitly left-aligned and expanding
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textPrimaryLight)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundStyle(StamerleeTheme.textSecondaryLight)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
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
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .background(cardColor, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
    }
}




public struct DashboardTabView: View {
    @Bindable public var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                modernTabView
            } else {
                legacyTabView
            }
        }
        .preferredColorScheme(.dark)
    }

    @available(iOS 18.0, *)
    private var modernTabView: some View {
        TabView(selection: state.selectedTabBinding) {
            Tab(
                AppTab.home.title,
                systemImage: AppTab.home.systemImage,
                value: AppTab.home
            ) {
                HomeDashboardView(state: state)
            }

            Tab(
                AppTab.summary.title,
                systemImage: AppTab.summary.systemImage,
                value: AppTab.summary
            ) {
                SummaryView(state: state)
            }
        }
        .tint(StamerleeTheme.primaryBlue)
        .sensoryFeedback(.selection, trigger: state.selectedTab)
    }

    private var legacyTabView: some View {
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
        .sensoryFeedback(.selection, trigger: state.selectedTab)
    }
}
