import SwiftUI
import Observation

// MARK: - Navigation Screens
public enum AppScreen: Hashable, CaseIterable {
    case launch
    case login
    case onboarding1
    case onboarding2
    case challengingSounds
    case exploreActivities
    case homeDashboard
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
    public var selectedTab: Int = 0 // 0: Home, 1: Insights, 2: Profile
    public var dailyPracticeMinutes: Int = 10
    public var currentStreakDays: Int = 3
    
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
    
    // UI Feedback States
    public var showEmailSheet: Bool = false
    public var showTermsSheet: Bool = false
    public var termsSheetTitle: String = ""
    public var termsSheetContent: String = ""
    
    public init() {}
    
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
            self.selectedSoundIds = ["td"]
            self.customSoundInput = ""
            self.isAuthenticated = false
            self.userEmail = ""
            self.selectedTab = 0
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
