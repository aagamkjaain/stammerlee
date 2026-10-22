import SwiftUI
import Observation

// MARK: - Navigation Screens
public enum AppScreen: Hashable, CaseIterable {
    case launch
    case login
    case onboarding1
    case onboarding2
    case challengingSounds
    case planReady
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
    
    public func selectSingleSound(id: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedSoundIds = [id]
        }
    }
    
    public func isSoundSelected(id: String) -> Bool {
        selectedSoundIds.contains(id)
    }
    
    public func restartFlow() {
        withAnimation(.easeInOut(duration: 0.35)) {
            self.currentScreen = .launch
            self.selectedSoundIds = ["td"]
            self.customSoundInput = ""
            self.isAuthenticated = false
            self.userEmail = ""
        }
    }
}
