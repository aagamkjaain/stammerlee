import Foundation
import SwiftUI
import Observation

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
    case pictureDescriptionDifficulty
    case pictureDescriptionPractice
    case dialScene
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
    
    // Auth State
    public var userEmail: String = ""
    public var isAuthenticated: Bool = false
    public var isAuthenticating: Bool = false
    public var authMethod: String? = nil
    
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
    public var selectedDifficulty: String = "Easy"
    public var completedProlongedDifficulties: Set<String> = []
    public var hasSeenProlongedSpeechIntro: Bool = false
    public var selectedPictureDescriptionDifficulty: String = "Easy"
    public var completedPictureDescriptionDifficulties: Set<String> = []
    public var hasCompletedDialScene: Bool = false
    public var selectedNarrationDifficulty: String = "Easy"
    public var completedNarrationDifficulties: Set<String> = []
    public var beatBuddySelectedWords: Set<String> = ["Water", "University"]
    public var beatBuddyBPM: Int = 120
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
        switch difficulty {
        case "Easy":
            return true
        case "Medium":
            return completedProlongedDifficulties.contains("Easy")
        case "Hard":
            return completedProlongedDifficulties.contains("Medium")
        default:
            return false
        }
    }

    public func completeProlongedDifficulty(_ difficulty: String) {
        completedProlongedDifficulties.insert(difficulty)
    }

    public var isPictureDescriptionUnlocked: Bool {
        completedProlongedDifficulties.contains("Hard")
    }

    public var isDialSceneUnlocked: Bool {
        completedPictureDescriptionDifficulties.contains("Hard")
    }

    public func isPictureDescriptionDifficultyUnlocked(_ difficulty: String) -> Bool {
        switch difficulty {
        case "Easy":
            return isPictureDescriptionUnlocked
        case "Medium":
            return completedPictureDescriptionDifficulties.contains("Easy")
        case "Hard":
            return completedPictureDescriptionDifficulties.contains("Medium")
        default:
            return false
        }
    }

    public var isBeatBuddyUnlocked: Bool {
        completedProlongedDifficulties.contains("Easy")
    }

    public var isNarrationUnlocked: Bool {
        hasCompletedDialScene
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
            self.hasSeenProlongedSpeechIntro = false
            self.selectedPictureDescriptionDifficulty = "Easy"
            self.completedPictureDescriptionDifficulties = []
            self.hasCompletedDialScene = false
            self.selectedNarrationDifficulty = "Easy"
            self.completedNarrationDifficulties = []
        }
    }
}
