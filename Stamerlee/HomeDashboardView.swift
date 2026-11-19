import SwiftUI
import UIKit

// MARK: - Home Dashboard View (Screenshot 2: "Welcome")
/// Main application hub with daily goals, exercise modules, and bottom tab bar.
public struct HomeDashboardView: View {
    @Bindable public var state: AppState
    @Environment(\.headerNamespace) private var headerNamespace
    
    @State private var showLockedAlert: Bool = false
    @State private var lockedAlertTitle: String = "Exercise Locked"
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
                            
                            // 1. Prolonged Speech (UNLOCKED from start - Level 1)
                            exerciseRow(
                                title: "Prolonged Speech",
                                subtitle: "Gently stretch sounds while speaking slowly.",
                                isLocked: !state.isProlongedSpeechUnlocked,
                                iconName: "IconProlongedSpeech"
                            ) {
                                state.navigate(
                                    to: state.hasSeenProlongedSpeechIntro
                                        ? .prolongedSpeechDifficulty
                                        : .prolongedSpeechIntro
                                )
                            }
                            
                            // 2. Picture Description (Level 2 - Unlocks after Prolonged Speech)
                            exerciseRow(
                                title: "Picture Description",
                                subtitle: "Practice by describing pictures in detail",
                                isLocked: !state.isPictureDescriptionUnlocked,
                                iconName: "IconPictureDesc"
                            ) {
                                state.navigate(
                                    to: state.hasSeenPictureDescriptionIntro
                                        ? .pictureDescriptionPractice
                                        : .pictureDescriptionIntro
                                )
                            }
                            
                            // 3. Dial Scene (Level 4 - Unlocks after Beat Buddy)
                            exerciseRow(
                                title: "Dial Scene",
                                subtitle: "Mimic speaking in different scenarios through interactive phone calls",
                                isLocked: !state.isDialSceneUnlocked,
                                iconName: "IconDialScene"
                            ) {
                                state.navigate(
                                    to: state.hasSeenDialSceneIntro
                                        ? .dialScene
                                        : .dialSceneIntro
                                )
                            }
                            
                            // 4. Narration (Level 5 - Unlocks after Dial Scene)
                            exerciseRow(
                                title: "Narration",
                                subtitle: "Speak about different topics infront of the mirror",
                                isLocked: !state.isNarrationUnlocked,
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
                            
                            // Beat Buddy (Level 3 - Unlocks after Picture Description)
                            exerciseRow(
                                title: "Beat Buddy",
                                subtitle: "Build your pace by speaking at every beat",
                                isLocked: !state.isBeatBuddyUnlocked,
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
                    .padding(.bottom, 36)
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            cardsAppeared = true
        }
        .alert(lockedAlertTitle, isPresented: $showLockedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(lockedAlertMessage)
        }
    }
    
    // MARK: - Top Header Image
    @ViewBuilder
    private var headerImageView: some View {
        Group {
            if let uiImage = UIImage(named: "Header") ?? UIImage(named: "header") ?? UIImage(named: "header 1") {
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

    // MARK: - Fluency Lap Card (with integrated Streak)
    private var fluencyLapCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Section: Illustration + Title + Streak Badge + Subtitle
            HStack(alignment: .center, spacing: 14) {
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
                .frame(width: 66, height: 66)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center) {
                        Text("Daily Challenge")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 20 / 255, green: 22 / 255, blue: 35 / 255))

                        Spacer()

                        // Streak Pill Badge
                        HStack(spacing: 4) {
                            if let uiImage = UIImage(named: "fire") ?? UIImage(contentsOfFile: Bundle.main.path(forResource: "fire", ofType: "png") ?? "") {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            } else {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color(red: 255 / 255, green: 130 / 255, blue: 60 / 255))
                            }
                            Text("\(max(state.currentStreakDays, 0))")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 110 / 255, green: 65 / 255, blue: 215 / 255))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(red: 236 / 255, green: 228 / 255, blue: 254 / 255), in: Capsule())
                    }

                    Text("Challenge yourself with a timed session and beat your score")
                        .font(.system(size: 12.5, weight: .medium, design: .rounded))
                        .foregroundStyle(StamerleeTheme.textSecondaryLight)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 7-Day Practice Streak Row
            HStack(spacing: 4) {
                ForEach(Array(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].enumerated()), id: \.offset) { index, day in
                    let completedDays = min(max(state.currentStreakDays, 0), 7)
                    let isCurrent = completedDays > 0 && index == completedDays - 1

                    VStack(spacing: 6) {
                        Text(day)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 35 / 255, green: 30 / 255, blue: 55 / 255))

                        if index < completedDays {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 76 / 255, green: 175 / 255, blue: 80 / 255))
                                    .frame(width: 24, height: 24)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        } else {
                            Circle()
                                .stroke(Color(red: 205 / 255, green: 200 / 255, blue: 232 / 255), lineWidth: 1.8)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        isCurrent ? Color(red: 228 / 255, green: 222 / 255, blue: 252 / 255) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)

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
                    .frame(height: 40)
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
            action: {
                if isLocked {
                    triggerLockedAlert(title: title)
                } else {
                    action()
                }
            }
        )
    }
    
    private func triggerLockedAlert(title: String) {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        switch title {
        case "Picture Description":
            lockedAlertTitle = "Picture Description Locked"
            lockedAlertMessage = "Complete a Prolonged Speech session first to unlock Picture Description!"
        case "Beat Buddy":
            lockedAlertTitle = "Beat Buddy Locked"
            lockedAlertMessage = "Attempt any one exercise at least once to unlock!"
        case "Dial Scene":
            lockedAlertTitle = "Dial Scene Locked"
            lockedAlertMessage = "Attempt a Picture Description exercise first to unlock Dial Scene!"
        case "Narration":
            lockedAlertTitle = "Narration Locked"
            lockedAlertMessage = "Complete a Dial Scene exercise first to unlock Narration!"
        default:
            lockedAlertTitle = "Exercise Locked"
            lockedAlertMessage = "\(title) will unlock as you progress level by level!"
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
        .buttonStyle(PopSpringButtonStyle(pressedScale: 0.97))
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var cardContent: some View {
        HStack(alignment: .center, spacing: 14) {
            // Leading Icon — kept vibrant as it was before
            Group {
                if let iconName {
                    Image(iconName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconName == "BeatBuddyLogo" ? 60 : 68, height: iconName == "BeatBuddyLogo" ? 60 : 68)
                }
            }
            .frame(width: 68, height: 68)

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

            // Trailing Chevron / Lock Icon — lock ONLY on the trailing side
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.gray.opacity(0.6))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.gray.opacity(0.5))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .background(
            cardColor,
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
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
        HomeDashboardView(state: state)
            .preferredColorScheme(.dark)
    }
}
