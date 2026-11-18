
import Foundation
import SwiftUI
import Observation
import UserNotifications

public enum AvatarHeroSlot: String, Hashable {
    case home
    case profile
}

// MARK: - App Tabs
public enum AppTab: Int, CaseIterable, Hashable {
    case home
    case summary

    public var title: String {
        switch self {
        case .home: return "Home"
        case .summary: return "Summary"
        }
    }

    public var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .summary: return "chart.bar.fill"
        }
    }
}

// MARK: - Navigation Screens
public enum AppScreen: Hashable, CaseIterable {
    case launch
    case welcome
    case onboarding1
    case onboarding2
    case login
    case nameInput
    case dailyGoal
    case exploreActivities
    case homeDashboard
    case profile
    case fluencyLapIntro
    case fluencyLap
    case fluencyLapCountdown
    case fluencyLapPractice
    case prolongedSpeechIntro
    case prolongedSpeechDifficulty
    case prolongedPractice
    case prolongedAnalysis
    case pictureDescriptionIntro
    case pictureDescriptionDifficulty
    case pictureDescriptionPractice
    case dialSceneIntro
    case dialScene
    case narrationIntro
    case narrationDifficulty
    case narrationPractice
    case beatBuddyIntro
    case beatBuddyBPM
    case beatBuddyPractice
    case exerciseProgressDetail
}

// MARK: - Exercise Detail Type
public enum ExerciseDetailType: String, CaseIterable, Identifiable, Hashable {
    case pictureDescription = "picture_desc"
    case prolongedSpeech = "prolonged_speech"
    case dialScene = "dial_scene"
    case narration = "narration"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .pictureDescription: return "Picture Description"
        case .prolongedSpeech: return "Prolonged Speech"
        case .dialScene: return "Dial Scene"
        case .narration: return "Narration"
        }
    }

    public var subtitle: String {
        switch self {
        case .pictureDescription:
            return "Describe a picture in your own words and build fluency."
        case .prolongedSpeech:
            return "Stretch vowel sounds smoothly to overcome blocks."
        case .dialScene:
            return "Practice realistic phone call conversations with pacing."
        case .narration:
            return "Read aloud and narrate stories with steady cadence."
        }
    }

    public var iconName: String {
        switch self {
        case .pictureDescription: return "IconPictureDesc"
        case .prolongedSpeech: return "IconProlongedSpeech"
        case .dialScene: return "IconDialScene"
        case .narration: return "IconMirrorNarration"
        }
    }

    public var defaultHighScore: Double {
        switch self {
        case .pictureDescription: return 9.6
        case .prolongedSpeech: return 8.5
        case .dialScene: return 7.8
        case .narration: return 8.9
        }
    }

    public var weeklyScores: [Double] {
        switch self {
        case .pictureDescription:
            return [6.8, 8.0, 7.0, 8.2, 7.6, 7.4, 9.6]
        case .prolongedSpeech:
            return [6.2, 7.1, 7.5, 7.0, 8.1, 7.9, 8.5]
        case .dialScene:
            return [5.5, 6.0, 6.4, 6.2, 7.0, 7.3, 7.8]
        case .narration:
            return [6.5, 7.0, 7.2, 7.8, 8.0, 8.4, 8.9]
        }
    }

    public var monthlyWeekScores: [Double] {
        switch self {
        case .pictureDescription:
            return [7.4, 8.2, 9.6, 8.8]
        case .prolongedSpeech:
            return [7.0, 7.8, 8.5, 8.2]
        case .dialScene:
            return [6.2, 7.0, 7.8, 7.4]
        case .narration:
            return [7.8, 8.6, 9.1, 8.9]
        }
    }

    public var overviewTitle: String {
        switch self {
        case .pictureDescription: return "Great effort this month!"
        case .prolongedSpeech: return "Smooth airflow achieved!"
        case .dialScene: return "Phone confidence growing!"
        case .narration: return "Exceptional cadence & tone!"
        }
    }

    public var overviewSubtitle: String {
        switch self {
        case .pictureDescription:
            return "Your progress has been solid — keep pushing and keep the rhythm going."
        case .prolongedSpeech:
            return "Consistent phonation and relaxed vocal cords are reducing blocks significantly."
        case .dialScene:
            return "Responses are flowing faster with fewer hesitations during scenario prompts."
        case .narration:
            return "Story pacing and rhythmic cadence are in sync across your readings."
        }
    }

    public func aiInsight(forWeekIndex weekIndex: Int) -> (title: String, insight: String, tip: String) {
        let week = weekIndex + 1
        switch self {
        case .pictureDescription:
            switch week {
            case 1:
                return (
                    "Initial Image Parsing",
                    "AI vocal analysis detected brief hesitations before complex scene vocabulary. Pacing remained consistent at 112 WPM.",
                    "Breathe gently into vowel-starting words to maintain smooth momentum."
                )
            case 2:
                return (
                    "Descriptive Fluency Gain",
                    "Acoustic tracking observed a 16% reduction in syllable repetitions during object descriptions.",
                    "Anchor your breath before switching between foreground and background details."
                )
            case 3:
                return (
                    "Peak Visual Narration",
                    "Exceptional speech flow! AI detected zero hard block episodes and 94% fluid phonation across descriptive sentences.",
                    "Keep this relaxed jaw position when expanding descriptions in real life."
                )
            default:
                return (
                    "Steady Cadence Maintained",
                    "Linguistic fluency metrics show 91% smooth speech transitions with steady diaphragmatic breath support.",
                    "Maintain your calm pre-speech visualization before complex phrases."
                )
            }
        case .prolongedSpeech:
            switch week {
            case 1:
                return (
                    "Airflow Foundation",
                    "Acoustic model recorded steady vowel elongations with initial tension on plosive consonants.",
                    "Focus on continuous voicing across word boundaries."
                )
            case 2:
                return (
                    "Continuous Phonation",
                    "Vocal fold vibration sensors detected smooth transitions with block durations dropping by 0.35s.",
                    "Use light articulatory contacts on 'b', 'd', and 'p' sounds."
                )
            case 3:
                return (
                    "Peak Glottal Flow",
                    "Outstanding vowel stretching! Neural speech analyzer recorded 93% airflow continuity and zero involuntary arrests.",
                    "Carry this relaxed airflow naturally into regular-tempo conversations."
                )
            default:
                return (
                    "Sustained Phonation Control",
                    "Airflow sensors indicate relaxed laryngeal tension and smooth voluntary sound stretching.",
                    "Practice transitioning from 2-second stretches into spontaneous conversation."
                )
            }
        case .dialScene:
            switch week {
            case 1:
                return (
                    "Call Scenario Baseline",
                    "AI speech monitor noted natural greeting cadence with mild hesitation on unexpected question turns.",
                    "Take a silent diaphragmatic pause before answering scenario questions."
                )
            case 2:
                return (
                    "Turn-Taking Confidence",
                    "Response latency decreased by 24%. Acoustic pacing held steady at 120 WPM throughout the scenario.",
                    "Speak at your own chosen pace without rushing to fill the silence."
                )
            case 3:
                return (
                    "Simulated Phone Mastery",
                    "Conversational fluency score peaked at 7.8! AI detected clean articulatory onsets under scenario pressure.",
                    "Apply this confident cadence when placing real-life phone calls."
                )
            default:
                return (
                    "Consistent Call Flow",
                    "Dialogue exchange shows smooth communicative flow and 88% block-free speech during phone simulation.",
                    "Keep steady vocal energy from the opening greeting to the call sign-off."
                )
            }
        case .narration:
            switch week {
            case 1:
                return (
                    "Mirror Cadence Baseline",
                    "AI detected consistent syllable timing with mild vocal cord tension on opening paragraph phrases.",
                    "Maintain eye contact with your reflection to foster speech confidence."
                )
            case 2:
                return (
                    "Cadence Stabilization",
                    "Rhythm analysis shows an 18% improvement in syllable pacing and smoother breath resets between sentences.",
                    "Soften your articulators on starting words like 'where' and 'that'."
                )
            case 3:
                return (
                    "Peak Expressive Fluency",
                    "Flawless narrative delivery! Neural audio evaluation verified zero stuttering blocks and a remarkable 9.1 fluency score.",
                    "Celebrate this peak! Your vocal cords were completely relaxed and in rhythm."
                )
            default:
                return (
                    "Mastered Narrative Delivery",
                    "Story cadence analysis confirms excellent rhythmic symmetry, natural pausing, and steady pitch modulation.",
                    "Use this smooth, expressive storytelling cadence in daily conversations."
                )
            }
        }
    }

    public func targetScreen(for state: AppState) -> AppScreen {
        switch self {
        case .pictureDescription:
            return state.hasSeenPictureDescriptionIntro ? .pictureDescriptionPractice : .pictureDescriptionIntro
        case .prolongedSpeech:
            return state.hasSeenProlongedSpeechIntro ? .prolongedSpeechDifficulty : .prolongedSpeechIntro
        case .dialScene:
            return state.hasSeenDialSceneIntro ? .dialScene : .dialSceneIntro
        case .narration:
            return state.hasSeenNarrationIntro ? .narrationPractice : .narrationIntro
        }
    }
}

// MARK: - Custom Dial Scene Scenario
/// A scenario the user created themselves in Dial Scene.
public struct CustomDialScenario: Identifiable, Hashable {
    public let id: UUID
    public var title: String
    public var details: String
    public var iconName: String

    public init(id: UUID = UUID(), title: String, details: String, iconName: String) {
        self.id = id
        self.title = title
        self.details = details
        self.iconName = iconName
    }
}

// MARK: - App State (Modern @Observable)
@Observable
public final class AppState {
    public var currentScreen: AppScreen = .launch
    public var previousScreen: AppScreen? = nil
    public var navigationDirection: Edge = .trailing
    public var heroAvatarHiddenSlot: AvatarHeroSlot? = nil
    public var isHeroAvatarTransitionActive = false
    
    public var isProfileTransition: Bool {
        (currentScreen == .profile && previousScreen == .homeDashboard) ||
        (currentScreen == .homeDashboard && previousScreen == .profile)
    }
    
    // Auth State (read-only outside AppState; mutate via signIn/logout/deleteAccount)
    public private(set) var userEmail: String = ""
    public private(set) var isAuthenticated: Bool = false
    public private(set) var authMethod: String? = nil
    
    // Dashboard & Tab State
    public var selectedTab: AppTab = .home
    public var fluencyLapWordCount: Int = 15
    public var hasCompletedFluencyLap: Bool = false
    public var hasCompletedFluencyLapIntro: Bool = false
    public var fluencyLapPreviousWordCount: Int = 42
    public var fluencyLapPersonalBest: Int = 56
    public var dailyPracticeMinutes: Int = 10
    public var currentStreakDays: Int = 3
    public var profileName: String = "Tanvi Nema"
    public var userName: String = ""
    /// Drives the glass sign-in overlay that pops up over Onboarding 2.
    public var isSigningIn: Bool = false
    public var profileAvatarStyle: Int = 0
    public var profileAvatarData: Data?
    
    // Practice & Difficulty State
    public var selectedDifficulty: String = "Words"
    public var completedProlongedDifficulties: Set<String> = []
    public var hasAttemptedProlongedEasy: Bool = false
    public var hasReceivedProlongedEasyScore: Bool = false
    public var prolongedEasyScore: Double? = nil
    public var prolongedSpeechScores: [String: Double] = [:]
    public var hasSeenProlongedSpeechIntro: Bool = false
    public var hasSeenPictureDescriptionIntro: Bool = false
    public var hasCompletedPictureDescription: Bool = false
    public var selectedPictureDescriptionDifficulty: String = "Easy"
    public var completedPictureDescriptionDifficulties: Set<String> = []
    public var hasCompletedDialScene: Bool = false
    public var customDialScenarios: [CustomDialScenario] = []
    public var hasSeenDialSceneIntro: Bool = false
    public var hasSeenNarrationIntro: Bool = false
    public var hasSeenBeatBuddyIntro: Bool = false
    public var hasCompletedBeatBuddy: Bool = false
    public var selectedNarrationDifficulty: String = "Easy"
    public var completedNarrationDifficulties: Set<String> = []
    public var selectedExerciseDetail: ExerciseDetailType = .pictureDescription

    // MARK: - Progressive Unlock (Level by Level)
    /// Fluency Lap is always open
    public var isFluencyLapUnlocked: Bool {
        true
    }

    /// Level 1: Prolonged Speech is open from the start
    public var isProlongedSpeechUnlocked: Bool {
        true
    }

    public var isProlongedSpeechCompleted: Bool {
        !completedProlongedDifficulties.isEmpty || hasAttemptedProlongedEasy || hasReceivedProlongedEasyScore
    }

    /// Level 2: Picture Description unlocks after completing Prolonged Speech
    public var isPictureDescriptionUnlocked: Bool {
        isProlongedSpeechCompleted
    }

    public var isPictureDescriptionCompleted: Bool {
        hasCompletedPictureDescription || !completedPictureDescriptionDifficulties.isEmpty
    }

    /// Level 3: Beat Buddy unlocks after completing Picture Description
    public var isBeatBuddyUnlocked: Bool {
        isPictureDescriptionCompleted
    }

    public var isBeatBuddyCompleted: Bool {
        hasCompletedBeatBuddy
    }

    /// Level 4: Dial Scene unlocks after completing Beat Buddy
    public var isDialSceneUnlocked: Bool {
        isBeatBuddyCompleted
    }

    public var isDialSceneCompleted: Bool {
        hasCompletedDialScene
    }

    /// Level 5: Narration unlocks after completing Dial Scene
    public var isNarrationUnlocked: Bool {
        isDialSceneCompleted
    }

    public var isNarrationCompleted: Bool {
        !completedNarrationDifficulties.isEmpty
    }
    public var beatBuddySelectedWords: Set<String> = ["Water", "University"]
    public var beatBuddyPracticeWords: [String] = []
    public var beatBuddySoundCategory: String = "Randomized"
    public var beatBuddyWordCount: Int = 10
    public var beatBuddyUsesCustomWordCount: Bool = false
    public var beatBuddyBPM: Int = 120
    public var beatBuddyDurationMinutes: Int = 2
    public var beatBuddySoundEnabled: Bool = true
    public var beatBuddyVibrationEnabled: Bool = true
    public var isAudioPracticing: Bool = false
    public var practiceAudioSeconds: Int = 0
    public var showPracticeModal: Bool = false

    // Reminder Notification State
    public var reminderEnabled: Bool = true
    public var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()

    public func signIn(method: String, email: String = "") {
        authMethod = method
        userEmail = email
        isAuthenticated = true
    }

    public func logout() {
        isAuthenticated = false
        userEmail = ""
        authMethod = nil
        navigate(to: .login, forward: false)
    }

    public func deleteAccount() {
        isAuthenticated = false
        userEmail = ""
        authMethod = nil
        profileAvatarData = nil
        profileName = "New User"
        currentStreakDays = 0
        practiceAudioSeconds = 0
        completedProlongedDifficulties.removeAll()
        hasCompletedPictureDescription = false
        completedPictureDescriptionDifficulties.removeAll()
        completedNarrationDifficulties.removeAll()
        hasCompletedDialScene = false
        hasCompletedBeatBuddy = false
        customDialScenarios.removeAll()
        hasAttemptedProlongedEasy = false
        hasReceivedProlongedEasyScore = false
        prolongedEasyScore = nil
        prolongedSpeechScores.removeAll()
        hasCompletedFluencyLap = false
        fluencyLapPreviousWordCount = 42
        fluencyLapPersonalBest = 56
        reminderEnabled = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        navigate(to: .login, forward: false)
    }
    
    public init() {}

    public func selectTab(_ tab: AppTab) {
        withAnimation(.easeInOut(duration: 0.22)) {
            selectedTab = tab
        }
    }
    
    // MARK: - Navigation Actions
    public func navigate(to screen: AppScreen, forward: Bool = true) {
        let sourceScreen = self.currentScreen
        if (sourceScreen == .homeDashboard && screen == .profile) || (sourceScreen == .profile && screen == .homeDashboard) {
            self.heroAvatarHiddenSlot = sourceScreen == .homeDashboard ? .home : .profile
            self.isHeroAvatarTransitionActive = true
        } else {
            self.heroAvatarHiddenSlot = nil
            self.isHeroAvatarTransitionActive = false
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
            self.previousScreen = sourceScreen
            self.navigationDirection = forward ? .trailing : .leading
            self.currentScreen = screen
        }
    }
    
    public func completeProlongedDifficulty(_ difficulty: String) {
        completedProlongedDifficulties.insert(difficulty)
    }

    public func recordProlongedScore(difficulty: String, score: Double) {
        prolongedSpeechScores[difficulty] = score
        completedProlongedDifficulties.insert(difficulty)
        if difficulty == "Words" || difficulty == "Easy" {
            hasAttemptedProlongedEasy = true
            hasReceivedProlongedEasyScore = true
            prolongedEasyScore = score
        }
    }

    public func completePictureDescription() {
        hasCompletedPictureDescription = true
        completedPictureDescriptionDifficulties.insert("Completed")
    }

    public func completeBeatBuddy() {
        hasCompletedBeatBuddy = true
    }

    public func completeNarration() {
        completedNarrationDifficulties.insert("Completed")
    }
}

