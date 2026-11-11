# Fluency Lap Screens: Modern SwiftUI Review

This document reviews the fluency tab binding, challenge setup screen, and practice screen with line-by-line explanations and a modern API/deprecation check.

## Screen flow

```text
DashboardTabView
  -> FluencyLapView
       -> FluencyLapPracticeView
            -> HomeDashboardView
```

| File/type | Responsibility |
|---|---|
| `AppTabNavigation.swift` | Exposes a two-way `selectedTabBinding` for `TabView`. |
| `FluencyLapView` | Lets the user choose Blitz, Classic, or Master duration. |
| `FluencyLapPracticeView` | Supplies words to reusable practice UI and handles completion. |
| `SpeakPracticeScreen` | Handles prompt display, progress, DAF state, microphone animation, and cancellable advancement. |

## Modern-code check

The implementation uses modern SwiftUI and Observation patterns. No definite deprecated API is present in these files.

- `@Bindable` with `AppState` is the current Observation-based shared-state pattern.
- `Binding(get:set:)` correctly exposes AppState selection to `TabView`.
- `CaseIterable` and `Identifiable` make the duration options type-safe and suitable for `ForEach`.
- `Task.sleep(for:)`, stored `Task` cancellation, and `.onDisappear` are modern structured-concurrency/lifecycle patterns.
- `.sensoryFeedback`, `#Preview`, accessibility traits, and availability-gated iOS 26 glass styles are modern APIs.
- Potential behavior issue, not deprecation: `promptCount` returns 1 for an empty prompt list, while `currentPrompt` is empty; provide an explicit empty-state UI if empty prompts are possible.
- Potential UI issue, not deprecation: the iOS 26 button style branch does not animate pressed scale like the fallback branch; verify interaction parity.
- Potential naming issue: the Classic duration displays 15 words, while `FluencyLapView` stores `selectedDuration.wordCount`; this is intentional if word count represents prompt count rather than duration seconds.

## Line-by-line explanation

### `Stamerlee/AppTabNavigation.swift` (11 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI for declarative UI, state, and modifiers. |
| 2 | `` | Blank line separating code sections. |
| 3 | `// MARK: - Shared Tab Navigation` | Section marker organizing the fluency feature. |
| 4 | `public extension AppState {` | Adds public functionality to AppState. |
| 5 | `    var selectedTabBinding: Binding<AppTab> {` | Declares a computed or mutable value. |
| 6 | `        Binding(` | Implements the surrounding fluency screen or view-builder expression. |
| 7 | `            get: { self.selectedTab },` | Implements the surrounding fluency screen or view-builder expression. |
| 8 | `            set: { self.selectTab($0) }` | Implements the surrounding fluency screen or view-builder expression. |
| 9 | `        )` | Implements the surrounding fluency screen or view-builder expression. |
| 10 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 11 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/FluencyLapView.swift` (175 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI for declarative UI, state, and modifiers. |
| 2 | `` | Blank line separating code sections. |
| 3 | `public struct FluencyLapView: View {` | Declares a reusable public SwiftUI view. |
| 4 | `    @Bindable public var state: AppState` | Connects the view to the observable AppState for two-way mutation. |
| 5 | `    @State private var selectedDuration: LapDuration = .classic` | Stores view-local state managed by SwiftUI. |
| 6 | `` | Blank line separating code sections. |
| 7 | `    public init(state: AppState) {` | Initializes the view with shared state or configuration. |
| 8 | `        self.state = state` | Implements the surrounding fluency screen or view-builder expression. |
| 9 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 10 | `` | Blank line separating code sections. |
| 11 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 12 | `        NavigationStack {` | Opens or closes a Swift scope or view-builder block. |
| 13 | `            ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 14 | `                StamerleeTheme.backgroundDark` | Implements the surrounding fluency screen or view-builder expression. |
| 15 | `                    .ignoresSafeArea()` | Extends the background into safe-area regions. |
| 16 | `` | Blank line separating code sections. |
| 17 | `                VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 18 | `                    BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 19 | `                        state.navigate(to: .homeDashboard, forward: false)` | Updates shared navigation state and moves to the requested screen. |
| 20 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 21 | `                    .padding(.top, 8)` | Adds layout spacing around the view. |
| 22 | `` | Blank line separating code sections. |
| 23 | `                    Text("Fluency Lap")` | Displays a text label. |
| 24 | `                        .font(.system(size: 30, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 25 | `                        .foregroundStyle(.white)` | Sets the foreground color or style. |
| 26 | `                        .padding(.top, 18)` | Adds layout spacing around the view. |
| 27 | `` | Blank line separating code sections. |
| 28 | `                    Text("Practice words from the sounds you tend to stutter on. Build speed, smoothness, and confidence under time pressure.")` | Displays a text label. |
| 29 | `                        .font(.system(size: 15, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 30 | `                        .foregroundStyle(Color(red: 221 / 255, green: 218 / 255, blue: 239 / 255))` | Sets the foreground color or style. |
| 31 | `                        .lineSpacing(4)` | Applies a SwiftUI modifier to the preceding view. |
| 32 | `                        .fixedSize(horizontal: false, vertical: true)` | Applies a SwiftUI modifier to the preceding view. |
| 33 | `                        .padding(.top, 10)` | Adds layout spacing around the view. |
| 34 | `` | Blank line separating code sections. |
| 35 | `                    goalCard` | Implements the surrounding fluency screen or view-builder expression. |
| 36 | `                        .padding(.top, 22)` | Adds layout spacing around the view. |
| 37 | `` | Blank line separating code sections. |
| 38 | `                    Text("CHOOSE ROUND DURATION")` | Displays a text label. |
| 39 | `                        .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 40 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 41 | `                        .tracking(0.6)` | Applies a SwiftUI modifier to the preceding view. |
| 42 | `                        .padding(.top, 26)` | Adds layout spacing around the view. |
| 43 | `` | Blank line separating code sections. |
| 44 | `                    HStack(spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 45 | `                        ForEach(LapDuration.allCases) { duration in` | Creates repeated SwiftUI views from the collection. |
| 46 | `                            durationButton(duration)` | Implements the surrounding fluency screen or view-builder expression. |
| 47 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 48 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 49 | `                    .padding(.top, 14)` | Adds layout spacing around the view. |
| 50 | `` | Blank line separating code sections. |
| 51 | `                    PrimaryActionButton(` | Uses the shared primary call-to-action component. |
| 52 | `                        title: "Start Today's Challenge",` | Implements the surrounding fluency screen or view-builder expression. |
| 53 | `                        icon: "play.fill",` | Implements the surrounding fluency screen or view-builder expression. |
| 54 | `                        compact: true` | Implements the surrounding fluency screen or view-builder expression. |
| 55 | `                    ) {` | Opens or closes a Swift scope or view-builder block. |
| 56 | `                        state.fluencyLapWordCount = selectedDuration.wordCount` | Implements the surrounding fluency screen or view-builder expression. |
| 57 | `                        state.navigate(to: .fluencyLapPractice)` | Updates shared navigation state and moves to the requested screen. |
| 58 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 59 | `                    .padding(.top, 28)` | Adds layout spacing around the view. |
| 60 | `` | Blank line separating code sections. |
| 61 | `                    Spacer(minLength: 0)` | Implements the surrounding fluency screen or view-builder expression. |
| 62 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 63 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 64 | `                .padding(.bottom, 12)` | Adds layout spacing around the view. |
| 65 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 66 | `            .toolbar(.hidden, for: .navigationBar)` | Applies a SwiftUI modifier to the preceding view. |
| 67 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 68 | `        .preferredColorScheme(.dark)` | Requests dark appearance for this view hierarchy. |
| 69 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 70 | `` | Blank line separating code sections. |
| 71 | `    private var goalCard: some View {` | Defines a computed helper view or value. |
| 72 | `        VStack(alignment: .leading, spacing: 8) {` | Opens or closes a Swift scope or view-builder block. |
| 73 | `            Text("Today's Challenge Goal")` | Displays a text label. |
| 74 | `                .font(.system(size: 18, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 75 | `                .foregroundStyle(StamerleeTheme.textPrimaryLight)` | Sets the foreground color or style. |
| 76 | `` | Blank line separating code sections. |
| 77 | `            Text("Speak words from your stuttered sounds with smooth, continuous airflow before time ends.")` | Displays a text label. |
| 78 | `                .font(.system(size: 14, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 79 | `                .foregroundStyle(Color(red: 79 / 255, green: 76 / 255, blue: 101 / 255))` | Sets the foreground color or style. |
| 80 | `                .lineSpacing(3)` | Applies a SwiftUI modifier to the preceding view. |
| 81 | `                .fixedSize(horizontal: false, vertical: true)` | Applies a SwiftUI modifier to the preceding view. |
| 82 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 83 | `        .padding(.horizontal, 20)` | Adds layout spacing around the view. |
| 84 | `        .padding(.vertical, 18)` | Adds layout spacing around the view. |
| 85 | `        .frame(maxWidth: .infinity, alignment: .leading)` | Constrains the view size or alignment. |
| 86 | `        .background(Color(red: 235 / 255, green: 232 / 255, blue: 255 / 255), in: RoundedRectangle(cornerRadius: 20, style: .continuous))` | Adds a background behind the content. |
| 87 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 88 | `` | Blank line separating code sections. |
| 89 | `    private func durationButton(_ duration: LapDuration) -> some View {` | Defines a private helper for interaction or state progression. |
| 90 | `        Button {` | Creates an interactive button. |
| 91 | `            withAnimation(.easeInOut(duration: 0.2)) {` | Animates the enclosed state mutation. |
| 92 | `                selectedDuration = duration` | Implements the surrounding fluency screen or view-builder expression. |
| 93 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 94 | `        } label: {` | Opens or closes a Swift scope or view-builder block. |
| 95 | `            VStack(spacing: 5) {` | Opens or closes a Swift scope or view-builder block. |
| 96 | `                Image(systemName: "stopwatch")` | Displays a system symbol. |
| 97 | `                    .font(.system(size: 18, weight: .medium))` | Sets typography, size, weight, and design. |
| 98 | `                Text(duration.title)` | Displays a text label. |
| 99 | `                    .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 100 | `                    .lineLimit(1)` | Applies a SwiftUI modifier to the preceding view. |
| 101 | `                    .minimumScaleFactor(0.85)` | Applies a SwiftUI modifier to the preceding view. |
| 102 | `                Text(duration.words)` | Displays a text label. |
| 103 | `                    .font(.system(size: 12, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 104 | `                    .foregroundStyle(.white.opacity(0.58))` | Sets the foreground color or style. |
| 105 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 106 | `            .foregroundStyle(.white)` | Sets the foreground color or style. |
| 107 | `            .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 108 | `            .padding(.vertical, 12)` | Adds layout spacing around the view. |
| 109 | `            .overlay(alignment: .topTrailing) {` | Draws an additional view above the content. |
| 110 | `                if selectedDuration == duration {` | Conditionally selects this behavior or view. |
| 111 | `                    Image(systemName: "checkmark.circle.fill")` | Displays a system symbol. |
| 112 | `                        .font(.system(size: 16))` | Sets typography, size, weight, and design. |
| 113 | `                        .foregroundStyle(.white)` | Sets the foreground color or style. |
| 114 | `                        .padding(6)` | Adds layout spacing around the view. |
| 115 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 116 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 117 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 118 | `        .buttonStyle(FluencyLapDurationButtonStyle(isSelected: selectedDuration == duration))` | Applies a SwiftUI modifier to the preceding view. |
| 119 | `        .accessibilityAddTraits(selectedDuration == duration ? .isSelected : [])` | Adds accessibility semantics or selection traits. |
| 120 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 121 | `}` | Opens or closes a Swift scope or view-builder block. |
| 122 | `` | Blank line separating code sections. |
| 123 | `private enum LapDuration: String, CaseIterable, Identifiable {` | Declares a private typed model for available round durations. |
| 124 | `    case blitz` | Handles one enum case. |
| 125 | `    case classic` | Handles one enum case. |
| 126 | `    case master` | Handles one enum case. |
| 127 | `` | Blank line separating code sections. |
| 128 | `    var id: String { rawValue }` | Declares a computed or mutable value. |
| 129 | `` | Blank line separating code sections. |
| 130 | `    var title: String {` | Declares a computed or mutable value. |
| 131 | `        switch self {` | Selects a value based on the current enum or state. |
| 132 | `        case .blitz: return "30s Blitz"` | Handles one enum case. |
| 133 | `        case .classic: return "45s Classic"` | Handles one enum case. |
| 134 | `        case .master: return "60s Master"` | Handles one enum case. |
| 135 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 136 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 137 | `` | Blank line separating code sections. |
| 138 | `    var words: String {` | Declares a computed or mutable value. |
| 139 | `        switch self {` | Selects a value based on the current enum or state. |
| 140 | `        case .blitz: return "7 words"` | Handles one enum case. |
| 141 | `        case .classic: return "15 words"` | Handles one enum case. |
| 142 | `        case .master: return "20 words"` | Handles one enum case. |
| 143 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 144 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 145 | `` | Blank line separating code sections. |
| 146 | `    var wordCount: Int {` | Declares a computed or mutable value. |
| 147 | `        switch self {` | Selects a value based on the current enum or state. |
| 148 | `        case .blitz: return 7` | Handles one enum case. |
| 149 | `        case .classic: return 15` | Handles one enum case. |
| 150 | `        case .master: return 20` | Handles one enum case. |
| 151 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 152 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 153 | `}` | Opens or closes a Swift scope or view-builder block. |
| 154 | `` | Blank line separating code sections. |
| 155 | `private struct FluencyLapDurationButtonStyle: ButtonStyle {` | Declares a private reusable SwiftUI button style. |
| 156 | `    let isSelected: Bool` | Declares immutable configuration or local data. |
| 157 | `` | Blank line separating code sections. |
| 158 | `    func makeBody(configuration: Configuration) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 159 | `        if #available(iOS 26.0, *) {` | Selects an implementation based on operating-system availability. |
| 160 | `            configuration.label` | Implements the surrounding fluency screen or view-builder expression. |
| 161 | `                .buttonStyle(.glass(.regular.tint(isSelected ? StamerleeTheme.primaryPurple : StamerleeTheme.cardDark).interactive()))` | Applies a SwiftUI modifier to the preceding view. |
| 162 | `                .buttonBorderShape(.roundedRectangle(radius: 16))` | Applies a SwiftUI modifier to the preceding view. |
| 163 | `                .scaleEffect(configuration.isPressed ? 0.97 : 1)` | Scales the view for press or listening animation. |
| 164 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 165 | `            configuration.label` | Implements the surrounding fluency screen or view-builder expression. |
| 166 | `                .background(isSelected ? StamerleeTheme.primaryPurple : StamerleeTheme.cardDark, in: RoundedRectangle(cornerRadius: 14, style: .continuous))` | Adds a background behind the content. |
| 167 | `                .overlay {` | Draws an additional view above the content. |
| 168 | `                    RoundedRectangle(cornerRadius: 14, style: .continuous)` | Implements the surrounding fluency screen or view-builder expression. |
| 169 | `                        .stroke(isSelected ? Color.white.opacity(0.7) : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)` | Applies a SwiftUI modifier to the preceding view. |
| 170 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 171 | `                .scaleEffect(configuration.isPressed ? 0.97 : 1)` | Scales the view for press or listening animation. |
| 172 | `                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)` | Associates an animation with changes to the supplied value. |
| 173 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 174 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 175 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/FluencyLapPracticeView.swift` (308 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports SwiftUI for declarative UI, state, and modifiers. |
| 2 | `` | Blank line separating code sections. |
| 3 | `public struct FluencyLapPracticeView: View {` | Declares a reusable public SwiftUI view. |
| 4 | `    @Bindable public var state: AppState` | Connects the view to the observable AppState for two-way mutation. |
| 5 | `` | Blank line separating code sections. |
| 6 | `    private let words = [` | Declares immutable configuration or local data. |
| 7 | `        "Wattttter",` | Implements the surrounding fluency screen or view-builder expression. |
| 8 | `        "Today",` | Implements the surrounding fluency screen or view-builder expression. |
| 9 | `        "People",` | Implements the surrounding fluency screen or view-builder expression. |
| 10 | `        "Together",` | Implements the surrounding fluency screen or view-builder expression. |
| 11 | `        "Please",` | Implements the surrounding fluency screen or view-builder expression. |
| 12 | `        "Morning",` | Implements the surrounding fluency screen or view-builder expression. |
| 13 | `        "Family",` | Implements the surrounding fluency screen or view-builder expression. |
| 14 | `        "Coffee",` | Implements the surrounding fluency screen or view-builder expression. |
| 15 | `        "Window",` | Implements the surrounding fluency screen or view-builder expression. |
| 16 | `        "Garden",` | Implements the surrounding fluency screen or view-builder expression. |
| 17 | `        "Breathe",` | Implements the surrounding fluency screen or view-builder expression. |
| 18 | `        "Quiet",` | Implements the surrounding fluency screen or view-builder expression. |
| 19 | `        "Gentle",` | Implements the surrounding fluency screen or view-builder expression. |
| 20 | `        "River",` | Implements the surrounding fluency screen or view-builder expression. |
| 21 | `        "Courage",` | Implements the surrounding fluency screen or view-builder expression. |
| 22 | `        "Practice",` | Implements the surrounding fluency screen or view-builder expression. |
| 23 | `        "Balance",` | Implements the surrounding fluency screen or view-builder expression. |
| 24 | `        "Freedom",` | Implements the surrounding fluency screen or view-builder expression. |
| 25 | `        "Journey",` | Implements the surrounding fluency screen or view-builder expression. |
| 26 | `        "Progress"` | Implements the surrounding fluency screen or view-builder expression. |
| 27 | `    ]` | Implements the surrounding fluency screen or view-builder expression. |
| 28 | `` | Blank line separating code sections. |
| 29 | `    public init(state: AppState) {` | Initializes the view with shared state or configuration. |
| 30 | `        self.state = state` | Implements the surrounding fluency screen or view-builder expression. |
| 31 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 32 | `` | Blank line separating code sections. |
| 33 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 34 | `        SpeakPracticeScreen(` | Uses the reusable speech-practice screen with custom prompts and callbacks. |
| 35 | `            prompts: Array(words.prefix(max(state.fluencyLapWordCount, 1))),` | Implements the surrounding fluency screen or view-builder expression. |
| 36 | `            onBack: {` | Opens or closes a Swift scope or view-builder block. |
| 37 | `                state.navigate(to: .fluencyLap, forward: false)` | Updates shared navigation state and moves to the requested screen. |
| 38 | `            },` | Implements the surrounding fluency screen or view-builder expression. |
| 39 | `            onFinish: {` | Opens or closes a Swift scope or view-builder block. |
| 40 | `                state.navigate(to: .homeDashboard, forward: false)` | Updates shared navigation state and moves to the requested screen. |
| 41 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 42 | `        )` | Implements the surrounding fluency screen or view-builder expression. |
| 43 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 44 | `}` | Opens or closes a Swift scope or view-builder block. |
| 45 | `` | Blank line separating code sections. |
| 46 | `public struct SpeakPracticeScreen: View {` | Declares a reusable public SwiftUI view. |
| 47 | `    let prompts: [String]` | Declares immutable configuration or local data. |
| 48 | `    let instruction: String` | Declares immutable configuration or local data. |
| 49 | `    let onBack: () -> Void` | Declares immutable configuration or local data. |
| 50 | `    let onFinish: () -> Void` | Declares immutable configuration or local data. |
| 51 | `    let allowsMultilinePrompt: Bool` | Declares immutable configuration or local data. |
| 52 | `` | Blank line separating code sections. |
| 53 | `    @State private var currentWordIndex = 0` | Stores view-local state managed by SwiftUI. |
| 54 | `    @State private var isDAFEnabled = true` | Stores view-local state managed by SwiftUI. |
| 55 | `    @State private var isListening = false` | Stores view-local state managed by SwiftUI. |
| 56 | `    @State private var pulse = false` | Stores view-local state managed by SwiftUI. |
| 57 | `    @State private var advanceTask: Task<Void, Never>?` | Stores view-local state managed by SwiftUI. |
| 58 | `` | Blank line separating code sections. |
| 59 | `    public init(` | Initializes the view with shared state or configuration. |
| 60 | `        prompts: [String],` | Implements the surrounding fluency screen or view-builder expression. |
| 61 | `        instruction: String = "Stretch the sounds gently as you speak, keeping each word slow, smooth, and relaxed.",` | Implements the surrounding fluency screen or view-builder expression. |
| 62 | `        allowsMultilinePrompt: Bool = false,` | Implements the surrounding fluency screen or view-builder expression. |
| 63 | `        onBack: @escaping () -> Void,` | Implements the surrounding fluency screen or view-builder expression. |
| 64 | `        onFinish: @escaping () -> Void` | Implements the surrounding fluency screen or view-builder expression. |
| 65 | `    ) {` | Opens or closes a Swift scope or view-builder block. |
| 66 | `        self.prompts = prompts` | Implements the surrounding fluency screen or view-builder expression. |
| 67 | `        self.instruction = instruction` | Implements the surrounding fluency screen or view-builder expression. |
| 68 | `        self.allowsMultilinePrompt = allowsMultilinePrompt` | Implements the surrounding fluency screen or view-builder expression. |
| 69 | `        self.onBack = onBack` | Implements the surrounding fluency screen or view-builder expression. |
| 70 | `        self.onFinish = onFinish` | Implements the surrounding fluency screen or view-builder expression. |
| 71 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 72 | `` | Blank line separating code sections. |
| 73 | `    private var promptCount: Int {` | Defines a computed helper view or value. |
| 74 | `        max(prompts.count, 1)` | Implements the surrounding fluency screen or view-builder expression. |
| 75 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 76 | `` | Blank line separating code sections. |
| 77 | `    private var currentPrompt: String {` | Defines a computed helper view or value. |
| 78 | `        guard !prompts.isEmpty else { return "" }` | Requires a condition and exits early when it fails. |
| 79 | `        return prompts[min(currentWordIndex, prompts.count - 1)]` | Implements the surrounding fluency screen or view-builder expression. |
| 80 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 81 | `` | Blank line separating code sections. |
| 82 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 83 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 84 | `            StamerleeTheme.backgroundDark` | Implements the surrounding fluency screen or view-builder expression. |
| 85 | `                .ignoresSafeArea()` | Extends the background into safe-area regions. |
| 86 | `` | Blank line separating code sections. |
| 87 | `            VStack(spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 88 | `                topBar` | Implements the surrounding fluency screen or view-builder expression. |
| 89 | `` | Blank line separating code sections. |
| 90 | `                Text(instruction)` | Displays a text label. |
| 91 | `                    .font(.system(size: 15, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 92 | `                    .foregroundStyle(Color(red: 190 / 255, green: 188 / 255, blue: 214 / 255))` | Sets the foreground color or style. |
| 93 | `                    .lineSpacing(5)` | Applies a SwiftUI modifier to the preceding view. |
| 94 | `                    .multilineTextAlignment(.leading)` | Applies a SwiftUI modifier to the preceding view. |
| 95 | `                    .frame(maxWidth: .infinity, alignment: .leading)` | Constrains the view size or alignment. |
| 96 | `                    .fixedSize(horizontal: false, vertical: true)` | Applies a SwiftUI modifier to the preceding view. |
| 97 | `                    .padding(.top, 28)` | Adds layout spacing around the view. |
| 98 | `` | Blank line separating code sections. |
| 99 | `                Spacer(minLength: 12)` | Implements the surrounding fluency screen or view-builder expression. |
| 100 | `` | Blank line separating code sections. |
| 101 | `                promptDisplay` | Implements the surrounding fluency screen or view-builder expression. |
| 102 | `` | Blank line separating code sections. |
| 103 | `                progress` | Implements the surrounding fluency screen or view-builder expression. |
| 104 | `                    .padding(.top, 22)` | Adds layout spacing around the view. |
| 105 | `` | Blank line separating code sections. |
| 106 | `                Spacer(minLength: 16)` | Implements the surrounding fluency screen or view-builder expression. |
| 107 | `` | Blank line separating code sections. |
| 108 | `                microphoneControl` | Implements the surrounding fluency screen or view-builder expression. |
| 109 | `` | Blank line separating code sections. |
| 110 | `                Text(allowsMultilinePrompt ? "Tap and speak the prompt" : "Tap and speak the word")` | Displays a text label. |
| 111 | `                    .font(.system(size: 14, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 112 | `                    .foregroundStyle(Color(red: 194 / 255, green: 192 / 255, blue: 218 / 255))` | Sets the foreground color or style. |
| 113 | `                    .padding(.top, 8)` | Adds layout spacing around the view. |
| 114 | `` | Blank line separating code sections. |
| 115 | `                Button {` | Creates an interactive button. |
| 116 | `                    finishPractice()` | Implements the surrounding fluency screen or view-builder expression. |
| 117 | `                } label: {` | Opens or closes a Swift scope or view-builder block. |
| 118 | `                    HStack(spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 119 | `                        Text("Finish Practice")` | Displays a text label. |
| 120 | `                            .font(.system(size: 17, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 121 | `                        Image(systemName: "arrow.right")` | Displays a system symbol. |
| 122 | `                            .font(.system(size: 18, weight: .bold))` | Sets typography, size, weight, and design. |
| 123 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 124 | `                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 125 | `                    .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 126 | `                    .frame(height: 52)` | Constrains the view size or alignment. |
| 127 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 128 | `                .buttonStyle(FluencyFinishButtonStyle())` | Applies a SwiftUI modifier to the preceding view. |
| 129 | `                .padding(.top, 22)` | Adds layout spacing around the view. |
| 130 | `                .padding(.bottom, 12)` | Adds layout spacing around the view. |
| 131 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 132 | `            .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 133 | `            .padding(.top, 8)` | Adds layout spacing around the view. |
| 134 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 135 | `        .preferredColorScheme(.dark)` | Requests dark appearance for this view hierarchy. |
| 136 | `        .onDisappear {` | Cancels pending work when the view leaves the hierarchy. |
| 137 | `            advanceTask?.cancel()` | Implements the surrounding fluency screen or view-builder expression. |
| 138 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 139 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 140 | `` | Blank line separating code sections. |
| 141 | `    private var topBar: some View {` | Defines a computed helper view or value. |
| 142 | `        HStack {` | Opens or closes a Swift scope or view-builder block. |
| 143 | `            BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 144 | `                advanceTask?.cancel()` | Implements the surrounding fluency screen or view-builder expression. |
| 145 | `                onBack()` | Implements the surrounding fluency screen or view-builder expression. |
| 146 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 147 | `` | Blank line separating code sections. |
| 148 | `            Spacer()` | Implements the surrounding fluency screen or view-builder expression. |
| 149 | `` | Blank line separating code sections. |
| 150 | `            Button {` | Creates an interactive button. |
| 151 | `                isDAFEnabled.toggle()` | Implements the surrounding fluency screen or view-builder expression. |
| 152 | `            } label: {` | Opens or closes a Swift scope or view-builder block. |
| 153 | `                Label("DAF", systemImage: "headphones")` | Implements the surrounding fluency screen or view-builder expression. |
| 154 | `                    .font(.system(size: 15, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 155 | `                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 156 | `                    .padding(.horizontal, 17)` | Adds layout spacing around the view. |
| 157 | `                    .frame(height: 40)` | Constrains the view size or alignment. |
| 158 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 159 | `            .buttonStyle(DAFButtonStyle(isEnabled: isDAFEnabled))` | Applies a SwiftUI modifier to the preceding view. |
| 160 | `            .accessibilityLabel(isDAFEnabled ? "Disable DAF" : "Enable DAF")` | Adds accessibility semantics or selection traits. |
| 161 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 162 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 163 | `` | Blank line separating code sections. |
| 164 | `    private var promptDisplay: some View {` | Defines a computed helper view or value. |
| 165 | `        let prompt = currentPrompt` | Declares immutable configuration or local data. |
| 166 | `        let highlighted = (` | Declares immutable configuration or local data. |
| 167 | `            Text(String(prompt.prefix(1)))` | Displays a text label. |
| 168 | `                .foregroundStyle(StamerleeTheme.accentPurpleLight)` | Sets the foreground color or style. |
| 169 | `            + Text(String(prompt.dropFirst()))` | Implements the surrounding fluency screen or view-builder expression. |
| 170 | `                .foregroundStyle(.white)` | Sets the foreground color or style. |
| 171 | `        )` | Implements the surrounding fluency screen or view-builder expression. |
| 172 | `        .font(.system(size: promptFontSize, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 173 | `        .multilineTextAlignment(.center)` | Applies a SwiftUI modifier to the preceding view. |
| 174 | `        .minimumScaleFactor(0.7)` | Applies a SwiftUI modifier to the preceding view. |
| 175 | `        .lineLimit(allowsMultilinePrompt ? 4 : 1)` | Applies a SwiftUI modifier to the preceding view. |
| 176 | `        .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 177 | `        .id(currentWordIndex)` | Applies a SwiftUI modifier to the preceding view. |
| 178 | `        .transition(.opacity.combined(with: .scale(scale: 0.96)))` | Applies a SwiftUI modifier to the preceding view. |
| 179 | `` | Blank line separating code sections. |
| 180 | `        return highlighted` | Implements the surrounding fluency screen or view-builder expression. |
| 181 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 182 | `` | Blank line separating code sections. |
| 183 | `    private var promptFontSize: CGFloat {` | Defines a computed helper view or value. |
| 184 | `        if !allowsMultilinePrompt {` | Conditionally selects this behavior or view. |
| 185 | `            return 46` | Implements the surrounding fluency screen or view-builder expression. |
| 186 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 187 | `        return currentPrompt.count > 42 ? 24 : 28` | Implements the surrounding fluency screen or view-builder expression. |
| 188 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 189 | `` | Blank line separating code sections. |
| 190 | `    private var progress: some View {` | Defines a computed helper view or value. |
| 191 | `        VStack(spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 192 | `            Text("\(currentWordIndex + 1) of \(promptCount)")` | Displays a text label. |
| 193 | `                .font(.system(size: 13, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 194 | `                .foregroundStyle(Color(red: 147 / 255, green: 145 / 255, blue: 175 / 255))` | Sets the foreground color or style. |
| 195 | `` | Blank line separating code sections. |
| 196 | `            HStack(spacing: 7) {` | Opens or closes a Swift scope or view-builder block. |
| 197 | `                ForEach(0..<min(promptCount, 8), id: \.self) { index in` | Creates repeated SwiftUI views from the collection. |
| 198 | `                    Circle()` | Implements the surrounding fluency screen or view-builder expression. |
| 199 | `                        .fill(index == currentWordIndex % min(promptCount, 8) ? .white : Color(red: 80 / 255, green: 79 / 255, blue: 111 / 255))` | Applies a SwiftUI modifier to the preceding view. |
| 200 | `                        .frame(width: 7, height: 7)` | Constrains the view size or alignment. |
| 201 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 202 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 203 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 204 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 205 | `` | Blank line separating code sections. |
| 206 | `    private var microphoneControl: some View {` | Defines a computed helper view or value. |
| 207 | `        Button {` | Creates an interactive button. |
| 208 | `            startListening()` | Implements the surrounding fluency screen or view-builder expression. |
| 209 | `        } label: {` | Opens or closes a Swift scope or view-builder block. |
| 210 | `            ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 211 | `                Circle()` | Implements the surrounding fluency screen or view-builder expression. |
| 212 | `                    .stroke(Color.white.opacity(0.08), lineWidth: 1)` | Applies a SwiftUI modifier to the preceding view. |
| 213 | `                    .frame(width: 148, height: 148)` | Constrains the view size or alignment. |
| 214 | `                    .scaleEffect(isListening && pulse ? 1.12 : 1)` | Scales the view for press or listening animation. |
| 215 | `                    .opacity(isListening ? (pulse ? 0.35 : 0.9) : 1)` | Applies a SwiftUI modifier to the preceding view. |
| 216 | `` | Blank line separating code sections. |
| 217 | `                Circle()` | Implements the surrounding fluency screen or view-builder expression. |
| 218 | `                    .stroke(StamerleeTheme.primaryPurple.opacity(isListening ? 0.45 : 0.25), lineWidth: 12)` | Applies a SwiftUI modifier to the preceding view. |
| 219 | `                    .frame(width: 126, height: 126)` | Constrains the view size or alignment. |
| 220 | `                    .scaleEffect(isListening && pulse ? 1.08 : 1)` | Scales the view for press or listening animation. |
| 221 | `                    .opacity(isListening ? (pulse ? 0.55 : 1) : 1)` | Applies a SwiftUI modifier to the preceding view. |
| 222 | `` | Blank line separating code sections. |
| 223 | `                Circle()` | Implements the surrounding fluency screen or view-builder expression. |
| 224 | `                    .fill(` | Applies a SwiftUI modifier to the preceding view. |
| 225 | `                        RadialGradient(` | Implements the surrounding fluency screen or view-builder expression. |
| 226 | `                            colors: [StamerleeTheme.accentPurpleLight, StamerleeTheme.primaryPurpleDark],` | Implements the surrounding fluency screen or view-builder expression. |
| 227 | `                            center: .topLeading,` | Implements the surrounding fluency screen or view-builder expression. |
| 228 | `                            startRadius: 2,` | Implements the surrounding fluency screen or view-builder expression. |
| 229 | `                            endRadius: 75` | Implements the surrounding fluency screen or view-builder expression. |
| 230 | `                        )` | Implements the surrounding fluency screen or view-builder expression. |
| 231 | `                    )` | Implements the surrounding fluency screen or view-builder expression. |
| 232 | `                    .frame(width: 96, height: 96)` | Constrains the view size or alignment. |
| 233 | `                    .shadow(color: StamerleeTheme.primaryPurple.opacity(isListening ? 0.95 : 0.7), radius: isListening ? 22 : 16)` | Applies a SwiftUI modifier to the preceding view. |
| 234 | `                    .scaleEffect(isListening && pulse ? 1.05 : 1)` | Scales the view for press or listening animation. |
| 235 | `` | Blank line separating code sections. |
| 236 | `                Image(systemName: "mic.fill")` | Displays a system symbol. |
| 237 | `                    .font(.system(size: 34, weight: .medium))` | Sets typography, size, weight, and design. |
| 238 | `                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 239 | `                    .scaleEffect(isListening && pulse ? 1.08 : 1)` | Scales the view for press or listening animation. |
| 240 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 241 | `            .frame(width: 168, height: 168)` | Constrains the view size or alignment. |
| 242 | `            .contentShape(Circle())` | Applies a SwiftUI modifier to the preceding view. |
| 243 | `            .animation(` | Associates an animation with changes to the supplied value. |
| 244 | `                isListening` | Implements the surrounding fluency screen or view-builder expression. |
| 245 | `                    ? .easeInOut(duration: 0.75).repeatForever(autoreverses: true)` | Implements the surrounding fluency screen or view-builder expression. |
| 246 | `                    : .easeOut(duration: 0.2),` | Implements the surrounding fluency screen or view-builder expression. |
| 247 | `                value: pulse` | Implements the surrounding fluency screen or view-builder expression. |
| 248 | `            )` | Implements the surrounding fluency screen or view-builder expression. |
| 249 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 250 | `        .buttonStyle(.haptic(weight: .medium, pressedScale: 0.96))` | Applies a SwiftUI modifier to the preceding view. |
| 251 | `        .disabled(isListening)` | Applies a SwiftUI modifier to the preceding view. |
| 252 | `        .accessibilityLabel(isListening ? "Listening" : "Speak word")` | Adds accessibility semantics or selection traits. |
| 253 | `        .sensoryFeedback(.impact(weight: .medium), trigger: isListening)` | Adds system haptic feedback driven by a state trigger. |
| 254 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 255 | `` | Blank line separating code sections. |
| 256 | `    private func startListening() {` | Defines a private helper for interaction or state progression. |
| 257 | `        guard !isListening else { return }` | Requires a condition and exits early when it fails. |
| 258 | `` | Blank line separating code sections. |
| 259 | `        advanceTask?.cancel()` | Implements the surrounding fluency screen or view-builder expression. |
| 260 | `        isListening = true` | Implements the surrounding fluency screen or view-builder expression. |
| 261 | `        pulse = true` | Implements the surrounding fluency screen or view-builder expression. |
| 262 | `` | Blank line separating code sections. |
| 263 | `        advanceTask = Task { @MainActor in` | Implements the surrounding fluency screen or view-builder expression. |
| 264 | `            try? await Task.sleep(for: .seconds(2))` | Waits asynchronously before advancing the practice prompt. |
| 265 | `            guard !Task.isCancelled else { return }` | Requires a condition and exits early when it fails. |
| 266 | `` | Blank line separating code sections. |
| 267 | `            withAnimation(.easeInOut(duration: 0.22)) {` | Animates the enclosed state mutation. |
| 268 | `                pulse = false` | Implements the surrounding fluency screen or view-builder expression. |
| 269 | `                isListening = false` | Implements the surrounding fluency screen or view-builder expression. |
| 270 | `                if currentWordIndex + 1 < promptCount {` | Conditionally selects this behavior or view. |
| 271 | `                    currentWordIndex += 1` | Implements the surrounding fluency screen or view-builder expression. |
| 272 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 273 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 274 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 275 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 276 | `` | Blank line separating code sections. |
| 277 | `    private func finishPractice() {` | Defines a private helper for interaction or state progression. |
| 278 | `        advanceTask?.cancel()` | Implements the surrounding fluency screen or view-builder expression. |
| 279 | `        isListening = false` | Implements the surrounding fluency screen or view-builder expression. |
| 280 | `        pulse = false` | Implements the surrounding fluency screen or view-builder expression. |
| 281 | `        onFinish()` | Implements the surrounding fluency screen or view-builder expression. |
| 282 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 283 | `}` | Opens or closes a Swift scope or view-builder block. |
| 284 | `` | Blank line separating code sections. |
| 285 | `private struct FluencyFinishButtonStyle: ButtonStyle {` | Declares a private reusable SwiftUI button style. |
| 286 | `    func makeBody(configuration: Configuration) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 287 | `        configuration.label` | Implements the surrounding fluency screen or view-builder expression. |
| 288 | `            .background(StamerleeTheme.primaryPurple, in: Capsule())` | Adds a background behind the content. |
| 289 | `            .scaleEffect(configuration.isPressed ? 0.97 : 1)` | Scales the view for press or listening animation. |
| 290 | `            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)` | Associates an animation with changes to the supplied value. |
| 291 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 292 | `}` | Opens or closes a Swift scope or view-builder block. |
| 293 | `` | Blank line separating code sections. |
| 294 | `private struct DAFButtonStyle: ButtonStyle {` | Declares a private reusable SwiftUI button style. |
| 295 | `    let isEnabled: Bool` | Declares immutable configuration or local data. |
| 296 | `` | Blank line separating code sections. |
| 297 | `    func makeBody(configuration: Configuration) -> some View {` | Opens or closes a Swift scope or view-builder block. |
| 298 | `        if #available(iOS 26.0, *) {` | Selects an implementation based on operating-system availability. |
| 299 | `            configuration.label` | Implements the surrounding fluency screen or view-builder expression. |
| 300 | `                .buttonStyle(.glass(.regular.tint(isEnabled ? StamerleeTheme.primaryBlue : StamerleeTheme.cardDark).interactive()))` | Applies a SwiftUI modifier to the preceding view. |
| 301 | `                .buttonBorderShape(.capsule)` | Applies a SwiftUI modifier to the preceding view. |
| 302 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 303 | `            configuration.label` | Implements the surrounding fluency screen or view-builder expression. |
| 304 | `                .background(isEnabled ? StamerleeTheme.primaryBlue : StamerleeTheme.cardDark, in: Capsule())` | Adds a background behind the content. |
| 305 | `                .scaleEffect(configuration.isPressed ? 0.96 : 1)` | Scales the view for press or listening animation. |
| 306 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 307 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 308 | `}` | Opens or closes a Swift scope or view-builder block. |

## Recommendations

- Add an empty-prompt state or precondition before rendering practice.
- Use a shared style helper if iOS 26 and fallback button interactions must remain visually identical.
- Replace hard-coded prompt data with a typed challenge model if Fluency Lap gains scoring, localization, or persistence.
- Consider a single cancellation-aware async action abstraction if microphone simulation becomes real speech recognition.
