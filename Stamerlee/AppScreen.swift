import Foundation
import SwiftUI
import Observation
import UserNotifications

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
    case login
    case onboarding1
    case onboarding2
    case dailyGoal
    case exploreActivities
    case homeDashboard
    case profile
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
    case beatBuddyWords
    case beatBuddyBPM
    case beatBuddyPractice
}

// MARK: - Sound Option Model
public struct SoundOption: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let isCustom: Bool
    
    public init(id: String, title: String, subtitle: String? = nil, isCustom: Bool = false) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isCustom = isCustom
    }
    
    public var displayLabel: String {
        if let subtitle = subtitle {
            return "\(title) (\(subtitle))"
        }
        return title
    }
}

// MARK: - Predefined Sound Options
extension SoundOption {
    public static let sampleOptions: [SoundOption] = [
        SoundOption(id: "pb", title: "P, B", subtitle: "Please, book"),
        SoundOption(id: "td", title: "T, D", subtitle: "Today, do"),
        SoundOption(id: "kg", title: "K, G", subtitle: "Come, go"),
        SoundOption(id: "other", title: "Something else", subtitle: nil, isCustom: true)
    ]
}

// MARK: - App State (Modern @Observable)
@Observable
public final class AppState {
    public var currentScreen: AppScreen = .launch
    public var navigationDirection: Edge = .trailing
    
    // Auth State (read-only outside AppState; mutate via signIn/logout/deleteAccount)
    public private(set) var userEmail: String = ""
    public private(set) var isAuthenticated: Bool = false
    public private(set) var authMethod: String? = nil
    
    // Challenging Sounds Selection
    public var selectedSoundIds: Set<String> = ["td"] // Default "T, D" selected as in screenshot
    public var customSoundInput: String = ""
    
    // Dashboard & Tab State
    public var selectedTab: AppTab = .home
    public var dailyPracticeMinutes: Int = 10
    public var currentStreakDays: Int = 3
    public var profileName: String = "John doe"
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
    public var hasSeenDialSceneIntro: Bool = false
    public var hasSeenNarrationIntro: Bool = false
    public var selectedNarrationDifficulty: String = "Easy"
    public var completedNarrationDifficulties: Set<String> = []
    public var beatBuddySelectedWords: Set<String> = ["Water", "University"]
    public var beatBuddyBPM: Int = 120
    public var beatBuddyDurationMinutes: Int = 2
    public var isAudioPracticing: Bool = false
    public var practiceAudioSeconds: Int = 0
    public var showPracticeModal: Bool = false

    public var dailyGoalProgress: Double {
        let goalSeconds = max(dailyPracticeMinutes, 1) * 60
        let recordedProgress = Double(practiceAudioSeconds) / Double(goalSeconds)
        return min(max(recordedProgress, 0.2), 1)
    }
    
    // UI Feedback States
    public var showEmailSheet: Bool = false
    public var showTermsSheet: Bool = false
    public var termsSheetTitle: String = ""
    public var termsSheetContent: String = ""
    
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
        hasAttemptedProlongedEasy = false
        hasReceivedProlongedEasyScore = false
        prolongedEasyScore = nil
        prolongedSpeechScores.removeAll()
        reminderEnabled = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        navigate(to: .login, forward: false)
    }
    
    public init() {}

    public func selectTab(_ tab: AppTab) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.easeInOut(duration: 0.22)) {
            selectedTab = tab
        }
    }
    
    // MARK: - Navigation Actions
    public func navigate(to screen: AppScreen, forward: Bool = true) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            self.navigationDirection = forward ? .trailing : .leading
            self.currentScreen = screen
        }
    }
    
    public func toggleSound(id: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedSoundIds.contains(id) {
                selectedSoundIds.remove(id)
            } else {
                selectedSoundIds.insert(id)
            }
        }
    }
    
    public func isSoundSelected(id: String) -> Bool {
        selectedSoundIds.contains(id)
    }

    public func isProlongedDifficultyUnlocked(_ difficulty: String) -> Bool {
        true
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

    public var isPictureDescriptionUnlocked: Bool {
        true
    }

    public func completePictureDescription() {
        hasCompletedPictureDescription = true
        completedPictureDescriptionDifficulties.insert("Completed")
    }

    public var isDialSceneUnlocked: Bool {
        true
    }

    public var isBeatBuddyUnlocked: Bool {
        true
    }

    public var isNarrationUnlocked: Bool {
        true
    }

    public func completeNarration() {
        completedNarrationDifficulties.insert("Completed")
    }
    
    public func restartFlow() {
        withAnimation(.easeInOut(duration: 0.35)) {
            self.currentScreen = .launch
            self.dailyPracticeMinutes = 10
            self.isAuthenticated = false
            self.userEmail = ""
            self.selectedTab = .home
            self.profileName = "John doe"
            self.profileAvatarStyle = 0
            self.profileAvatarData = nil
            self.completedProlongedDifficulties = []
            self.hasAttemptedProlongedEasy = false
            self.hasReceivedProlongedEasyScore = false
            self.prolongedEasyScore = nil
            self.prolongedSpeechScores = [:]
            self.hasSeenProlongedSpeechIntro = false
            self.selectedPictureDescriptionDifficulty = "Easy"
            self.completedPictureDescriptionDifficulties = []
            self.hasCompletedDialScene = false
            self.selectedNarrationDifficulty = "Easy"
            self.completedNarrationDifficulties = []
        }
    }
}
