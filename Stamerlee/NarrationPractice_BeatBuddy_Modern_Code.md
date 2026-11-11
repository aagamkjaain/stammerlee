# Narration Practice and Beat Buddy: Modern SwiftUI Review

This document reviews the screens shown in the supplied screenshot, with line-by-line explanations and a modern API/deprecation check.

## Screen flow

```text
NarrationIntroView
  -> NarrationPracticeView
       -> ExerciseAnalysisSkeletonView

BeatBuddyWordsView
  -> BeatBuddyBPMView
       -> BeatBuddyPracticeView
            -> Beat Buddy completion
```

## Modern-code check

The implementation uses modern SwiftUI, Observation, structured-concurrency, and UIKit-bridge patterns. No definite deprecated API is present in these files.

- `@Bindable` with `AppState` is the current Observation-based shared-state pattern.
- `UIViewRepresentable` remains the standard bridge for embedding the AVFoundation camera preview in SwiftUI.
- `Task.sleep(for:)`, `#Preview`, `Menu`, `sensoryFeedback`, computed `some View` properties, and state-driven conditional rendering are modern APIs/patterns.
- Camera session start/stop work is moved off the main thread, which is appropriate for AVFoundation.
- Potential behavior issue, not deprecation: camera permission denial currently produces no user-facing explanation or recovery action.
- Potential lifecycle issue: the camera session is stopped asynchronously, but `CameraPreviewView` does not expose a cancellation token for a pending start.
- Potential state issue: `NarrationPracticeView.complete()` can be called repeatedly from microphone and Finish controls; guard against duplicate completion if the action becomes asynchronous.
- Beat Buddy uses raw strings for words and practice settings; typed models would improve safety, but this is not a deprecation issue.
- Repeated RGB literals in Beat Buddy should be moved into `StamerleeTheme` design tokens.

## Line-by-line explanation

### `Stamerlee/NarrationPracticeView.swift` (232 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework needed by this source file. |
| 2 | `import AVFoundation` | Imports the framework needed by this source file. |
| 3 | `` | Blank line separating code sections. |
| 4 | `// MARK: - Narration Practice` | Section marker organizing the implementation. |
| 5 | `/// Guided narration practice with a level-specific prompt and analysis result.` | Comment describing the purpose of the following code. |
| 6 | `public struct NarrationPracticeView: View {` | Declares a reusable SwiftUI view. |
| 7 | `    @Bindable public var state: AppState` | Connects the view to the observable AppState for two-way mutation. |
| 8 | `    @State private var showAnalysis = false` | Stores view-local state managed by SwiftUI. |
| 9 | `    @State private var isListening = false` | Stores view-local state managed by SwiftUI. |
| 10 | `` | Blank line separating code sections. |
| 11 | `    public init(state: AppState) {` | Initializes the view with state and configuration. |
| 12 | `        self.state = state` | Implements the surrounding screen, camera, or view-builder expression. |
| 13 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 14 | `` | Blank line separating code sections. |
| 15 | `    private var difficulty: String { state.selectedNarrationDifficulty }` | Defines a computed helper view or value. |
| 16 | `` | Blank line separating code sections. |
| 17 | `    private var prompt: String {` | Defines a computed helper view or value. |
| 18 | `        switch difficulty {` | Selects behavior based on the current state or setting. |
| 19 | `        case "Medium": return "Describe what happened first,\nthen explain what happens next"` | Handles one enum or switch case. |
| 20 | `        case "Hard": return "Tell a complete story with a beginning,\nmiddle, and ending"` | Handles one enum or switch case. |
| 21 | `        default: return "Describe yourself and your hobbies"` | Implements the surrounding screen, camera, or view-builder expression. |
| 22 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 23 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 24 | `` | Blank line separating code sections. |
| 25 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 26 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 27 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen, camera, or view-builder expression. |
| 28 | `            if showAnalysis { analysisView } else { practiceView }` | Conditionally selects this behavior or view. |
| 29 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 30 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 31 | `` | Blank line separating code sections. |
| 32 | `    private var practiceView: some View {` | Defines a computed helper view or value. |
| 33 | `        VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 34 | `            HStack {` | Opens or closes a Swift scope or view-builder block. |
| 35 | `                BackNavButton { state.navigate(to: .homeDashboard, forward: false) }` | Implements the surrounding screen, camera, or view-builder expression. |
| 36 | `                Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 37 | `                Text("DAF")` | Displays a text label. |
| 38 | `                    .font(.system(size: 12, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 39 | `                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 40 | `                    .padding(.horizontal, 14)` | Adds layout spacing around the view. |
| 41 | `                    .padding(.vertical, 7)` | Adds layout spacing around the view. |
| 42 | `                    .background(StamerleeTheme.primaryBlueDark)` | Adds a background behind the content. |
| 43 | `                    .clipShape(Capsule())` | Clips content to a supplied shape. |
| 44 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 45 | `            .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 46 | `            .padding(.top, 16)` | Adds layout spacing around the view. |
| 47 | `` | Blank line separating code sections. |
| 48 | `            Text("Narration")` | Displays a text label. |
| 49 | `                .font(.system(size: 30, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 50 | `                .foregroundStyle(.white)` | Sets the foreground color or style. |
| 51 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 52 | `                .padding(.top, 22)` | Adds layout spacing around the view. |
| 53 | `` | Blank line separating code sections. |
| 54 | `            Text(prompt)` | Displays a text label. |
| 55 | `                .font(.system(size: 14, design: .rounded))` | Sets typography, size, weight, and design. |
| 56 | `                .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 57 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 58 | `                .padding(.top, 10)` | Adds layout spacing around the view. |
| 59 | `` | Blank line separating code sections. |
| 60 | `            SelfieCameraPreview()` | Implements the surrounding screen, camera, or view-builder expression. |
| 61 | `                .frame(maxWidth: .infinity, maxHeight: .infinity)` | Constrains the view size or alignment. |
| 62 | `                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))` | Clips content to a supplied shape. |
| 63 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 64 | `                .padding(.top, 24)` | Adds layout spacing around the view. |
| 65 | `` | Blank line separating code sections. |
| 66 | `            Text(prompt)` | Displays a text label. |
| 67 | `                .font(.system(size: 12, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 68 | `                .foregroundStyle(.black)` | Sets the foreground color or style. |
| 69 | `                .padding(.horizontal, 14)` | Adds layout spacing around the view. |
| 70 | `                .padding(.vertical, 8)` | Adds layout spacing around the view. |
| 71 | `                .background(Color.white)` | Adds a background behind the content. |
| 72 | `                .clipShape(Capsule())` | Clips content to a supplied shape. |
| 73 | `                .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 74 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 75 | `                .padding(.top, 12)` | Adds layout spacing around the view. |
| 76 | `` | Blank line separating code sections. |
| 77 | `            Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 78 | `` | Blank line separating code sections. |
| 79 | `            SpeechMicrophoneButton(isListening: $isListening) {` | Opens or closes a Swift scope or view-builder block. |
| 80 | `                isListening = true` | Implements the surrounding screen, camera, or view-builder expression. |
| 81 | `                complete()` | Implements the surrounding screen, camera, or view-builder expression. |
| 82 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 83 | `            .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 84 | `            .padding(.bottom, 26)` | Adds layout spacing around the view. |
| 85 | `` | Blank line separating code sections. |
| 86 | `            PrimaryActionButton(title: "Finish") { complete() }` | Implements the surrounding screen, camera, or view-builder expression. |
| 87 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 88 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 89 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 90 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 91 | `` | Blank line separating code sections. |
| 92 | `    private var wordsList: [String] {` | Defines a computed helper view or value. |
| 93 | `        switch difficulty {` | Selects behavior based on the current state or setting. |
| 94 | `        case "Medium":` | Handles one enum or switch case. |
| 95 | `            return [` | Implements the surrounding screen, camera, or view-builder expression. |
| 96 | `                "Sequence", "Detail", "Beginning", "Next", "Transition", "Flow",` | Implements the surrounding screen, camera, or view-builder expression. |
| 97 | `                "Explanation", "Storyline", "Moment", "Remember", "Action", "Context",` | Implements the surrounding screen, camera, or view-builder expression. |
| 98 | `                "Pacing", "Natural", "Breathe", "Voice", "Clarity", "Presence"` | Implements the surrounding screen, camera, or view-builder expression. |
| 99 | `            ]` | Implements the surrounding screen, camera, or view-builder expression. |
| 100 | `        case "Hard":` | Handles one enum or switch case. |
| 101 | `            return [` | Implements the surrounding screen, camera, or view-builder expression. |
| 102 | `                "Narrative", "Character", "Conflict", "Resolution", "Journey", "Perspective",` | Implements the surrounding screen, camera, or view-builder expression. |
| 103 | `                "Expression", "Meaning", "Imagination", "Experience", "Articulate", "Emotion",` | Implements the surrounding screen, camera, or view-builder expression. |
| 104 | `                "Reflection", "Confidence", "Delivery", "Speaking", "Insight", "Connection"` | Implements the surrounding screen, camera, or view-builder expression. |
| 105 | `            ]` | Implements the surrounding screen, camera, or view-builder expression. |
| 106 | `        default:` | Implements the surrounding screen, camera, or view-builder expression. |
| 107 | `            return [` | Implements the surrounding screen, camera, or view-builder expression. |
| 108 | `                "Dance", "University", "Breaking", "Computer", "Arts", "Laptop",` | Implements the surrounding screen, camera, or view-builder expression. |
| 109 | `                "Water", "Plants", "Teacher", "Science", "Communication", "Interaction",` | Implements the surrounding screen, camera, or view-builder expression. |
| 110 | `                "Story", "People", "Picture", "Sentence", "Practice", "Together"` | Implements the surrounding screen, camera, or view-builder expression. |
| 111 | `            ]` | Implements the surrounding screen, camera, or view-builder expression. |
| 112 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 113 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 114 | `` | Blank line separating code sections. |
| 115 | `    private var scoreText: String {` | Defines a computed helper view or value. |
| 116 | `        switch difficulty {` | Selects behavior based on the current state or setting. |
| 117 | `        case "Hard":` | Handles one enum or switch case. |
| 118 | `            return "8.1"` | Implements the surrounding screen, camera, or view-builder expression. |
| 119 | `        case "Medium":` | Handles one enum or switch case. |
| 120 | `            return "8.7"` | Implements the surrounding screen, camera, or view-builder expression. |
| 121 | `        default:` | Implements the surrounding screen, camera, or view-builder expression. |
| 122 | `            return "9.3"` | Implements the surrounding screen, camera, or view-builder expression. |
| 123 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 124 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 125 | `` | Blank line separating code sections. |
| 126 | `    private var analysisView: some View {` | Defines a computed helper view or value. |
| 127 | `        ExerciseAnalysisSkeletonView(` | Implements the surrounding screen, camera, or view-builder expression. |
| 128 | `            scoreText: scoreText,` | Implements the surrounding screen, camera, or view-builder expression. |
| 129 | `            maxScoreText: "/ 10",` | Implements the surrounding screen, camera, or view-builder expression. |
| 130 | `            onDone: {` | Opens or closes a Swift scope or view-builder block. |
| 131 | `                state.navigate(to: .homeDashboard)` | Implements the surrounding screen, camera, or view-builder expression. |
| 132 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 133 | `        )` | Implements the surrounding screen, camera, or view-builder expression. |
| 134 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 135 | `` | Blank line separating code sections. |
| 136 | `    private func complete() {` | Defines a private helper for state, layout, or behavior. |
| 137 | `        state.completeNarration()` | Implements the surrounding screen, camera, or view-builder expression. |
| 138 | `        withAnimation(.easeInOut(duration: 0.25)) {` | Animates the enclosed state mutation. |
| 139 | `            showAnalysis = true` | Implements the surrounding screen, camera, or view-builder expression. |
| 140 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 141 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 142 | `}` | Opens or closes a Swift scope or view-builder block. |
| 143 | `` | Blank line separating code sections. |
| 144 | `private struct SelfieCameraPreview: UIViewRepresentable {` | Declares a reusable SwiftUI view. |
| 145 | `    func makeUIView(context: Context) -> CameraPreviewView {` | Creates the UIKit view used by the SwiftUI bridge. |
| 146 | `        let view = CameraPreviewView()` | Declares immutable configuration or local data. |
| 147 | `        view.startSession()` | Implements the surrounding screen, camera, or view-builder expression. |
| 148 | `        return view` | Implements the surrounding screen, camera, or view-builder expression. |
| 149 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 150 | `` | Blank line separating code sections. |
| 151 | `    func updateUIView(_ uiView: CameraPreviewView, context: Context) {}` | Updates the UIKit view when SwiftUI state changes. |
| 152 | `` | Blank line separating code sections. |
| 153 | `    static func dismantleUIView(_ uiView: CameraPreviewView, coordinator: ()) {` | Cleans up the UIKit view when SwiftUI removes it. |
| 154 | `        uiView.stopSession()` | Implements the surrounding screen, camera, or view-builder expression. |
| 155 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 156 | `}` | Opens or closes a Swift scope or view-builder block. |
| 157 | `` | Blank line separating code sections. |
| 158 | `private final class CameraPreviewView: UIView {` | Declares a private UIKit-backed camera view object. |
| 159 | `    private let session = AVCaptureSession()` | Declares immutable configuration or local data. |
| 160 | `    private var isConfigured = false` | Defines a computed helper view or value. |
| 161 | `` | Blank line separating code sections. |
| 162 | `    override class var layerClass: AnyClass {` | Uses AVCaptureVideoPreviewLayer as the UIKit view’s backing layer. |
| 163 | `        AVCaptureVideoPreviewLayer.self` | Implements the surrounding screen, camera, or view-builder expression. |
| 164 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 165 | `` | Blank line separating code sections. |
| 166 | `    private var previewLayer: AVCaptureVideoPreviewLayer {` | Defines a computed helper view or value. |
| 167 | `        layer as! AVCaptureVideoPreviewLayer` | Implements the surrounding screen, camera, or view-builder expression. |
| 168 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 169 | `` | Blank line separating code sections. |
| 170 | `    func startSession() {` | Opens or closes a Swift scope or view-builder block. |
| 171 | `        switch AVCaptureDevice.authorizationStatus(for: .video) {` | Selects behavior based on the current state or setting. |
| 172 | `        case .authorized:` | Handles one enum or switch case. |
| 173 | `            configureAndStart()` | Implements the surrounding screen, camera, or view-builder expression. |
| 174 | `        case .notDetermined:` | Handles one enum or switch case. |
| 175 | `            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in` | Requests camera permission from the user. |
| 176 | `                guard granted else { return }` | Requires a condition and exits early if it fails. |
| 177 | `                DispatchQueue.main.async {` | Moves camera session work to an appropriate dispatch queue. |
| 178 | `                    self?.configureAndStart()` | Implements the surrounding screen, camera, or view-builder expression. |
| 179 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 180 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 181 | `        default:` | Implements the surrounding screen, camera, or view-builder expression. |
| 182 | `            break` | Implements the surrounding screen, camera, or view-builder expression. |
| 183 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 184 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 185 | `` | Blank line separating code sections. |
| 186 | `    func stopSession() {` | Opens or closes a Swift scope or view-builder block. |
| 187 | `        guard session.isRunning else { return }` | Requires a condition and exits early if it fails. |
| 188 | `        DispatchQueue.global(qos: .userInitiated).async { [session] in` | Moves camera session work to an appropriate dispatch queue. |
| 189 | `            session.stopRunning()` | Implements the surrounding screen, camera, or view-builder expression. |
| 190 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 191 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 192 | `` | Blank line separating code sections. |
| 193 | `    private func configureAndStart() {` | Defines a private helper for state, layout, or behavior. |
| 194 | `        guard !isConfigured else {` | Requires a condition and exits early if it fails. |
| 195 | `            startRunning()` | Implements the surrounding screen, camera, or view-builder expression. |
| 196 | `            return` | Implements the surrounding screen, camera, or view-builder expression. |
| 197 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 198 | `` | Blank line separating code sections. |
| 199 | `        session.beginConfiguration()` | Implements the surrounding screen, camera, or view-builder expression. |
| 200 | `        session.sessionPreset = .high` | Implements the surrounding screen, camera, or view-builder expression. |
| 201 | `        defer {` | Opens or closes a Swift scope or view-builder block. |
| 202 | `            session.commitConfiguration()` | Implements the surrounding screen, camera, or view-builder expression. |
| 203 | `            isConfigured = true` | Implements the surrounding screen, camera, or view-builder expression. |
| 204 | `            previewLayer.session = session` | Implements the surrounding screen, camera, or view-builder expression. |
| 205 | `            previewLayer.videoGravity = .resizeAspectFill` | Implements the surrounding screen, camera, or view-builder expression. |
| 206 | `            startRunning()` | Implements the surrounding screen, camera, or view-builder expression. |
| 207 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 208 | `` | Blank line separating code sections. |
| 209 | `        guard` | Implements the surrounding screen, camera, or view-builder expression. |
| 210 | `            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),` | Declares immutable configuration or local data. |
| 211 | `            let input = try? AVCaptureDeviceInput(device: camera),` | Declares immutable configuration or local data. |
| 212 | `            session.canAddInput(input)` | Implements the surrounding screen, camera, or view-builder expression. |
| 213 | `        else {` | Provides the fallback branch. |
| 214 | `            return` | Implements the surrounding screen, camera, or view-builder expression. |
| 215 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 216 | `` | Blank line separating code sections. |
| 217 | `        session.addInput(input)` | Implements the surrounding screen, camera, or view-builder expression. |
| 218 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 219 | `` | Blank line separating code sections. |
| 220 | `    private func startRunning() {` | Defines a private helper for state, layout, or behavior. |
| 221 | `        guard !session.isRunning else { return }` | Requires a condition and exits early if it fails. |
| 222 | `        DispatchQueue.global(qos: .userInitiated).async { [session] in` | Moves camera session work to an appropriate dispatch queue. |
| 223 | `            session.startRunning()` | Implements the surrounding screen, camera, or view-builder expression. |
| 224 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 225 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 226 | `}` | Opens or closes a Swift scope or view-builder block. |
| 227 | `` | Blank line separating code sections. |
| 228 | `#Preview("Narration Practice") {` | Declares a modern SwiftUI preview. |
| 229 | `    @Previewable @State var state = AppState()` | Implements the surrounding screen, camera, or view-builder expression. |
| 230 | `` | Blank line separating code sections. |
| 231 | `    NarrationPracticeView(state: state)` | Implements the surrounding screen, camera, or view-builder expression. |
| 232 | `}` | Opens or closes a Swift scope or view-builder block. |

### `Stamerlee/BeatBuddyViews.swift` (792 lines)

| Line | Source | Explanation |
|---:|---|---|
| 1 | `import SwiftUI` | Imports the framework needed by this source file. |
| 2 | `` | Blank line separating code sections. |
| 3 | `private let defaultBeatBuddyWords = [` | Declares immutable configuration or local data. |
| 4 | `    "Water", "University", "Breaking", "Computer", "Scale", "Laptop",` | Implements the surrounding screen, camera, or view-builder expression. |
| 5 | `    "Vinyl", "Desk", "Swift", "Center", "Protocol", "Optional",` | Implements the surrounding screen, camera, or view-builder expression. |
| 6 | `    "Morning", "Coffee", "Please", "Breathe", "Gentle", "Together",` | Implements the surrounding screen, camera, or view-builder expression. |
| 7 | `    "Pacing", "Speech", "Natural", "Freedom", "Balance", "Progress",` | Implements the surrounding screen, camera, or view-builder expression. |
| 8 | `    "Connection", "Confidence", "Smooth", "Presence", "Story", "Clarity"` | Implements the surrounding screen, camera, or view-builder expression. |
| 9 | `]` | Implements the surrounding screen, camera, or view-builder expression. |
| 10 | `` | Blank line separating code sections. |
| 11 | `private struct BeatBuddyShell<Content: View>: View {` | Declares a reusable SwiftUI view. |
| 12 | `    @Bindable var state: AppState` | Connects the view to the observable AppState for two-way mutation. |
| 13 | `    var onBack: (() -> Void)? = nil` | Declares a computed or mutable value. |
| 14 | `    let content: Content` | Declares immutable configuration or local data. |
| 15 | `` | Blank line separating code sections. |
| 16 | `    init(state: AppState, onBack: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {` | Initializes the view with state and configuration. |
| 17 | `        self.state = state` | Implements the surrounding screen, camera, or view-builder expression. |
| 18 | `        self.onBack = onBack` | Implements the surrounding screen, camera, or view-builder expression. |
| 19 | `        self.content = content()` | Implements the surrounding screen, camera, or view-builder expression. |
| 20 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 21 | `` | Blank line separating code sections. |
| 22 | `    var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 23 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 24 | `            StamerleeTheme.backgroundDark.ignoresSafeArea()` | Implements the surrounding screen, camera, or view-builder expression. |
| 25 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 26 | `                BackNavButton {` | Opens or closes a Swift scope or view-builder block. |
| 27 | `                    if let onBack {` | Conditionally uses an optional value when present. |
| 28 | `                        onBack()` | Implements the surrounding screen, camera, or view-builder expression. |
| 29 | `                    } else {` | Opens or closes a Swift scope or view-builder block. |
| 30 | `                        state.navigate(to: .homeDashboard, forward: false)` | Implements the surrounding screen, camera, or view-builder expression. |
| 31 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 32 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 33 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 34 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 35 | `                content` | Implements the surrounding screen, camera, or view-builder expression. |
| 36 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 37 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 38 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 39 | `}` | Opens or closes a Swift scope or view-builder block. |
| 40 | `` | Blank line separating code sections. |
| 41 | `// MARK: - Practice Option Card` | Section marker organizing the implementation. |
| 42 | `private struct PracticeOptionCard: View {` | Declares a reusable SwiftUI view. |
| 43 | `    let title: String` | Declares immutable configuration or local data. |
| 44 | `    let subtitle: String` | Declares immutable configuration or local data. |
| 45 | `    let systemImage: String` | Declares immutable configuration or local data. |
| 46 | `    let action: () -> Void` | Declares immutable configuration or local data. |
| 47 | `` | Blank line separating code sections. |
| 48 | `    var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 49 | `        Button(action: {` | Creates an interactive button. |
| 50 | `            action()` | Implements the surrounding screen, camera, or view-builder expression. |
| 51 | `        }) {` | Opens or closes a Swift scope or view-builder block. |
| 52 | `            HStack(alignment: .center, spacing: 14) {` | Opens or closes a Swift scope or view-builder block. |
| 53 | `                // Leading Icon Logo` | Comment describing the purpose of the following code. |
| 54 | `                ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 55 | `                    Circle()` | Implements the surrounding screen, camera, or view-builder expression. |
| 56 | `                        .fill(Color(red: 228 / 255, green: 220 / 255, blue: 255 / 255))` | Applies a SwiftUI modifier to the preceding view. |
| 57 | `                        .frame(width: 52, height: 52)` | Constrains the view size or alignment. |
| 58 | `` | Blank line separating code sections. |
| 59 | `                    Image(systemName: systemImage)` | Displays an image asset or SF Symbol. |
| 60 | `                        .font(.system(size: 22, weight: .semibold))` | Sets typography, size, weight, and design. |
| 61 | `                        .foregroundStyle(Color(red: 90 / 255, green: 76 / 255, blue: 160 / 255))` | Sets the foreground color or style. |
| 62 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 63 | `` | Blank line separating code sections. |
| 64 | `                // Title and Subtitle on the right` | Comment describing the purpose of the following code. |
| 65 | `                VStack(alignment: .leading, spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 66 | `                    Text(title)` | Displays a text label. |
| 67 | `                        .font(.system(size: 20, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 68 | `                        .foregroundStyle(Color(red: 18 / 255, green: 16 / 255, blue: 38 / 255))` | Sets the foreground color or style. |
| 69 | `` | Blank line separating code sections. |
| 70 | `                    Text(subtitle)` | Displays a text label. |
| 71 | `                        .font(.system(size: 13, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 72 | `                        .foregroundStyle(Color(red: 105 / 255, green: 98 / 255, blue: 142 / 255))` | Sets the foreground color or style. |
| 73 | `                        .lineSpacing(1.5)` | Applies a SwiftUI modifier to the preceding view. |
| 74 | `                        .lineLimit(3)` | Applies a SwiftUI modifier to the preceding view. |
| 75 | `                        .multilineTextAlignment(.leading)` | Applies a SwiftUI modifier to the preceding view. |
| 76 | `                        .fixedSize(horizontal: false, vertical: true)` | Applies a SwiftUI modifier to the preceding view. |
| 77 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 78 | `                .frame(maxWidth: .infinity, alignment: .leading)` | Constrains the view size or alignment. |
| 79 | `` | Blank line separating code sections. |
| 80 | `                // Trailing Chevron` | Comment describing the purpose of the following code. |
| 81 | `                Image(systemName: "chevron.right")` | Displays an image asset or SF Symbol. |
| 82 | `                    .font(.system(size: 14, weight: .bold))` | Sets typography, size, weight, and design. |
| 83 | `                    .foregroundStyle(Color(red: 108 / 255, green: 92 / 255, blue: 168 / 255))` | Sets the foreground color or style. |
| 84 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 85 | `            .padding(.horizontal, 18)` | Adds layout spacing around the view. |
| 86 | `            .padding(.vertical, 16)` | Adds layout spacing around the view. |
| 87 | `            .frame(maxWidth: .infinity, minHeight: 104)` | Constrains the view size or alignment. |
| 88 | `            .background(` | Adds a background behind the content. |
| 89 | `                ZStack(alignment: .topTrailing) {` | Opens or closes a Swift scope or view-builder block. |
| 90 | `                    RoundedRectangle(cornerRadius: 20, style: .continuous)` | Implements the surrounding screen, camera, or view-builder expression. |
| 91 | `                        .fill(Color(red: 243 / 255, green: 240 / 255, blue: 254 / 255))` | Applies a SwiftUI modifier to the preceding view. |
| 92 | `` | Blank line separating code sections. |
| 93 | `                    // Soft ambient highlight` | Comment describing the purpose of the following code. |
| 94 | `                    Circle()` | Implements the surrounding screen, camera, or view-builder expression. |
| 95 | `                        .fill(Color(red: 228 / 255, green: 220 / 255, blue: 255 / 255).opacity(0.85))` | Applies a SwiftUI modifier to the preceding view. |
| 96 | `                        .frame(width: 90, height: 90)` | Constrains the view size or alignment. |
| 97 | `                        .offset(x: 20, y: -20)` | Applies a SwiftUI modifier to the preceding view. |
| 98 | `                        .blur(radius: 8)` | Applies a SwiftUI modifier to the preceding view. |
| 99 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 100 | `            )` | Implements the surrounding screen, camera, or view-builder expression. |
| 101 | `            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))` | Clips content to a supplied shape. |
| 102 | `            .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)` | Adds visual depth with a shadow. |
| 103 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 104 | `        .buttonStyle(.haptic(weight: .medium, pressedScale: 0.98))` | Applies a SwiftUI modifier to the preceding view. |
| 105 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 106 | `}` | Opens or closes a Swift scope or view-builder block. |
| 107 | `` | Blank line separating code sections. |
| 108 | `` | Blank line separating code sections. |
| 109 | `// MARK: - 1. Word Selection Screen` | Section marker organizing the implementation. |
| 110 | `public struct BeatBuddyWordsView: View {` | Declares a reusable SwiftUI view. |
| 111 | `    @Bindable public var state: AppState` | Connects the view to the observable AppState for two-way mutation. |
| 112 | `    public var onBack: (() -> Void)? = nil` | Implements the surrounding screen, camera, or view-builder expression. |
| 113 | `    public var onContinue: (() -> Void)? = nil` | Implements the surrounding screen, camera, or view-builder expression. |
| 114 | `    @State private var searchText = ""` | Stores view-local state managed by SwiftUI. |
| 115 | `    @State private var customWordCountText = ""` | Stores view-local state managed by SwiftUI. |
| 116 | `    @State private var showInfo = false` | Stores view-local state managed by SwiftUI. |
| 117 | `` | Blank line separating code sections. |
| 118 | `    public init(state: AppState, onBack: (() -> Void)? = nil, onContinue: (() -> Void)? = nil) {` | Initializes the view with state and configuration. |
| 119 | `        self.state = state` | Implements the surrounding screen, camera, or view-builder expression. |
| 120 | `        self.onBack = onBack` | Implements the surrounding screen, camera, or view-builder expression. |
| 121 | `        self.onContinue = onContinue` | Implements the surrounding screen, camera, or view-builder expression. |
| 122 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 123 | `` | Blank line separating code sections. |
| 124 | `    private var allWords: [String] {` | Defines a computed helper view or value. |
| 125 | `        var words = defaultBeatBuddyWords` | Declares a computed or mutable value. |
| 126 | `        for word in state.beatBuddySelectedWords {` | Opens or closes a Swift scope or view-builder block. |
| 127 | `            if !words.contains(word) {` | Conditionally selects this behavior or view. |
| 128 | `                words.insert(word, at: 0)` | Implements the surrounding screen, camera, or view-builder expression. |
| 129 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 130 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 131 | `        return words` | Implements the surrounding screen, camera, or view-builder expression. |
| 132 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 133 | `` | Blank line separating code sections. |
| 134 | `    private var filteredWords: [String] {` | Defines a computed helper view or value. |
| 135 | `        allWords.filter { searchText.isEmpty \|\| $0.localizedCaseInsensitiveContains(searchText) }` | Implements the surrounding screen, camera, or view-builder expression. |
| 136 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 137 | `` | Blank line separating code sections. |
| 138 | `    private var isAllSelected: Bool {` | Defines a computed helper view or value. |
| 139 | `        !filteredWords.isEmpty && filteredWords.allSatisfy { state.beatBuddySelectedWords.contains($0) }` | Implements the surrounding screen, camera, or view-builder expression. |
| 140 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 141 | `` | Blank line separating code sections. |
| 142 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 143 | `        BeatBuddyShell(state: state, onBack: {` | Opens or closes a Swift scope or view-builder block. |
| 144 | `            if let onBack {` | Conditionally uses an optional value when present. |
| 145 | `                onBack()` | Implements the surrounding screen, camera, or view-builder expression. |
| 146 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 147 | `                state.navigate(to: .homeDashboard, forward: false)` | Implements the surrounding screen, camera, or view-builder expression. |
| 148 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 149 | `        }) {` | Opens or closes a Swift scope or view-builder block. |
| 150 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 151 | `                // Screen Headings` | Comment describing the purpose of the following code. |
| 152 | `                HStack(alignment: .top) {` | Opens or closes a Swift scope or view-builder block. |
| 153 | `                    Text("Select Words")` | Displays a text label. |
| 154 | `                        .font(.system(size: 30, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 155 | `                        .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style. |
| 156 | `` | Blank line separating code sections. |
| 157 | `                    Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 158 | `` | Blank line separating code sections. |
| 159 | `                    Button {` | Creates an interactive button. |
| 160 | `                        showInfo = true` | Implements the surrounding screen, camera, or view-builder expression. |
| 161 | `                    } label: {` | Opens or closes a Swift scope or view-builder block. |
| 162 | `                        Image(systemName: "info.circle.fill")` | Displays an image asset or SF Symbol. |
| 163 | `                            .font(.system(size: 22, weight: .semibold))` | Sets typography, size, weight, and design. |
| 164 | `                            .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 165 | `                            .frame(width: 44, height: 44)` | Constrains the view size or alignment. |
| 166 | `                            .contentShape(Rectangle())` | Applies a SwiftUI modifier to the preceding view. |
| 167 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 168 | `                    .accessibilityLabel("About Beat Buddy words")` | Adds accessibility semantics. |
| 169 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 170 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 171 | `                .padding(.top, 20)` | Adds layout spacing around the view. |
| 172 | `` | Blank line separating code sections. |
| 173 | `                Text("Choose the words you want to practice with Beat Buddy")` | Displays a text label. |
| 174 | `                    .font(.system(size: 16, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 175 | `                    .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 176 | `                    .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 177 | `                    .padding(.top, 8)` | Adds layout spacing around the view. |
| 178 | `                    .lineLimit(2)` | Applies a SwiftUI modifier to the preceding view. |
| 179 | `` | Blank line separating code sections. |
| 180 | `                HStack(spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 181 | `                    Button {` | Creates an interactive button. |
| 182 | `                        randomizeWords()` | Implements the surrounding screen, camera, or view-builder expression. |
| 183 | `                    } label: {` | Opens or closes a Swift scope or view-builder block. |
| 184 | `                        Label("Randomize", systemImage: "shuffle")` | Displays text with a system-image label. |
| 185 | `                            .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 186 | `                            .foregroundStyle(.white)` | Sets the foreground color or style. |
| 187 | `                            .padding(.horizontal, 14)` | Adds layout spacing around the view. |
| 188 | `                            .frame(height: 40)` | Constrains the view size or alignment. |
| 189 | `                            .background(StamerleeTheme.primaryBlue, in: Capsule())` | Adds a background behind the content. |
| 190 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 191 | `` | Blank line separating code sections. |
| 192 | `                    Menu {` | Creates a menu containing selectable actions. |
| 193 | `                        ForEach([10, 15, 20], id: \.self) { count in` | Creates repeated SwiftUI views from a collection. |
| 194 | `                            Button("\(count) words") {` | Creates an interactive button. |
| 195 | `                                state.beatBuddyWordCount = count` | Implements the surrounding screen, camera, or view-builder expression. |
| 196 | `                                state.beatBuddyUsesCustomWordCount = false` | Implements the surrounding screen, camera, or view-builder expression. |
| 197 | `                                randomizeWords()` | Implements the surrounding screen, camera, or view-builder expression. |
| 198 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 199 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 200 | `                        Button("Custom") {` | Creates an interactive button. |
| 201 | `                            state.beatBuddyUsesCustomWordCount = true` | Implements the surrounding screen, camera, or view-builder expression. |
| 202 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 203 | `                    } label: {` | Opens or closes a Swift scope or view-builder block. |
| 204 | `                        Label(` | Displays text with a system-image label. |
| 205 | `                            state.beatBuddyUsesCustomWordCount ? "\(state.beatBuddyWordCount) words" : "\(state.beatBuddyWordCount) words",` | Implements the surrounding screen, camera, or view-builder expression. |
| 206 | `                            systemImage: "chevron.down"` | Implements the surrounding screen, camera, or view-builder expression. |
| 207 | `                        )` | Implements the surrounding screen, camera, or view-builder expression. |
| 208 | `                        .font(.system(size: 13, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 209 | `                        .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style. |
| 210 | `                        .padding(.horizontal, 14)` | Adds layout spacing around the view. |
| 211 | `                        .frame(height: 40)` | Constrains the view size or alignment. |
| 212 | `                        .background(Color.white.opacity(0.1), in: Capsule())` | Adds a background behind the content. |
| 213 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 214 | `` | Blank line separating code sections. |
| 215 | `                    if state.beatBuddyUsesCustomWordCount {` | Conditionally selects this behavior or view. |
| 216 | `                        TextField("Count", text: $customWordCountText)` | Implements the surrounding screen, camera, or view-builder expression. |
| 217 | `                            .keyboardType(.numberPad)` | Applies a SwiftUI modifier to the preceding view. |
| 218 | `                            .font(.system(size: 13, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 219 | `                            .foregroundStyle(.white)` | Sets the foreground color or style. |
| 220 | `                            .frame(width: 56, height: 40)` | Constrains the view size or alignment. |
| 221 | `                            .multilineTextAlignment(.center)` | Applies a SwiftUI modifier to the preceding view. |
| 222 | `                            .background(Color.white.opacity(0.1), in: Capsule())` | Adds a background behind the content. |
| 223 | `                            .onSubmit {` | Opens or closes a Swift scope or view-builder block. |
| 224 | `                                applyCustomWordCount()` | Implements the surrounding screen, camera, or view-builder expression. |
| 225 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 226 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 227 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 228 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 229 | `                .padding(.top, 16)` | Adds layout spacing around the view. |
| 230 | `` | Blank line separating code sections. |
| 231 | `                // Search Bar` | Comment describing the purpose of the following code. |
| 232 | `                HStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 233 | `                    Image(systemName: "magnifyingglass")` | Displays an image asset or SF Symbol. |
| 234 | `                        .font(.system(size: 17, weight: .semibold))` | Sets typography, size, weight, and design. |
| 235 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 236 | `` | Blank line separating code sections. |
| 237 | `                    TextField("Search words...", text: $searchText)` | Implements the surrounding screen, camera, or view-builder expression. |
| 238 | `                        .font(.system(size: 15, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 239 | `                        .foregroundStyle(.white)` | Sets the foreground color or style. |
| 240 | `                        .tint(StamerleeTheme.primaryBlue)` | Applies a SwiftUI modifier to the preceding view. |
| 241 | `` | Blank line separating code sections. |
| 242 | `                    if !searchText.isEmpty {` | Conditionally selects this behavior or view. |
| 243 | `                        Button {` | Creates an interactive button. |
| 244 | `                            searchText = ""` | Implements the surrounding screen, camera, or view-builder expression. |
| 245 | `                        } label: {` | Opens or closes a Swift scope or view-builder block. |
| 246 | `                            Image(systemName: "xmark.circle.fill")` | Displays an image asset or SF Symbol. |
| 247 | `                                .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 248 | `                                .font(.system(size: 16))` | Sets typography, size, weight, and design. |
| 249 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 250 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 251 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 252 | `                .padding(.horizontal, 16)` | Adds layout spacing around the view. |
| 253 | `                .frame(height: 50)` | Constrains the view size or alignment. |
| 254 | `                .background(Color.white.opacity(0.07))` | Adds a background behind the content. |
| 255 | `                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))` | Clips content to a supplied shape. |
| 256 | `                .overlay(` | Draws an additional view above the content. |
| 257 | `                    RoundedRectangle(cornerRadius: 16, style: .continuous)` | Implements the surrounding screen, camera, or view-builder expression. |
| 258 | `                        .stroke(Color.white.opacity(0.1), lineWidth: 1)` | Applies a SwiftUI modifier to the preceding view. |
| 259 | `                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 260 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 261 | `                .padding(.top, 20)` | Adds layout spacing around the view. |
| 262 | `` | Blank line separating code sections. |
| 263 | `                // Action Row: Counter + Single Toggle Button` | Comment describing the purpose of the following code. |
| 264 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 265 | `                    Text("\(state.beatBuddySelectedWords.count) selected")` | Displays a text label. |
| 266 | `                        .font(.system(size: 13, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 267 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 268 | `` | Blank line separating code sections. |
| 269 | `                    Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 270 | `` | Blank line separating code sections. |
| 271 | `                    Button(isAllSelected ? "Deselect all" : "Select all") {` | Creates an interactive button. |
| 272 | `                        withAnimation(.easeInOut(duration: 0.2)) {` | Animates the enclosed state mutation. |
| 273 | `                            if isAllSelected {` | Conditionally selects this behavior or view. |
| 274 | `                                for word in filteredWords {` | Opens or closes a Swift scope or view-builder block. |
| 275 | `                                    state.beatBuddySelectedWords.remove(word)` | Implements the surrounding screen, camera, or view-builder expression. |
| 276 | `                                }` | Opens or closes a Swift scope or view-builder block. |
| 277 | `                            } else {` | Opens or closes a Swift scope or view-builder block. |
| 278 | `                                for word in filteredWords {` | Opens or closes a Swift scope or view-builder block. |
| 279 | `                                    state.beatBuddySelectedWords.insert(word)` | Implements the surrounding screen, camera, or view-builder expression. |
| 280 | `                                }` | Opens or closes a Swift scope or view-builder block. |
| 281 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 282 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 283 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 284 | `                    .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 285 | `                    .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 286 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 287 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 288 | `                .padding(.top, 14)` | Adds layout spacing around the view. |
| 289 | `                .padding(.bottom, 6)` | Adds layout spacing around the view. |
| 290 | `` | Blank line separating code sections. |
| 291 | `                // Scrollable Words Grid (Larger Cards)` | Comment describing the purpose of the following code. |
| 292 | `                ScrollView(showsIndicators: false) {` | Opens or closes a Swift scope or view-builder block. |
| 293 | `                    LazyVGrid(` | Implements the surrounding screen, camera, or view-builder expression. |
| 294 | `                        columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],` | Implements the surrounding screen, camera, or view-builder expression. |
| 295 | `                        spacing: 14` | Implements the surrounding screen, camera, or view-builder expression. |
| 296 | `                    ) {` | Opens or closes a Swift scope or view-builder block. |
| 297 | `                        ForEach(filteredWords, id: \.self) { word in` | Creates repeated SwiftUI views from a collection. |
| 298 | `                            let isSelected = state.beatBuddySelectedWords.contains(word)` | Declares immutable configuration or local data. |
| 299 | `                            Button {` | Creates an interactive button. |
| 300 | `                                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {` | Animates the enclosed state mutation. |
| 301 | `                                    if isSelected {` | Conditionally selects this behavior or view. |
| 302 | `                                        state.beatBuddySelectedWords.remove(word)` | Implements the surrounding screen, camera, or view-builder expression. |
| 303 | `                                    } else {` | Opens or closes a Swift scope or view-builder block. |
| 304 | `                                        state.beatBuddySelectedWords.insert(word)` | Implements the surrounding screen, camera, or view-builder expression. |
| 305 | `                                    }` | Opens or closes a Swift scope or view-builder block. |
| 306 | `                                }` | Opens or closes a Swift scope or view-builder block. |
| 307 | `                            } label: {` | Opens or closes a Swift scope or view-builder block. |
| 308 | `                                HStack(spacing: 10) {` | Opens or closes a Swift scope or view-builder block. |
| 309 | `                                    Text(word)` | Displays a text label. |
| 310 | `                                        .font(.system(size: 16, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 311 | `                                        .foregroundStyle(isSelected ? .white : StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style. |
| 312 | `` | Blank line separating code sections. |
| 313 | `                                    if isSelected {` | Conditionally selects this behavior or view. |
| 314 | `                                        Image(systemName: "checkmark.circle.fill")` | Displays an image asset or SF Symbol. |
| 315 | `                                            .font(.system(size: 17, weight: .bold))` | Sets typography, size, weight, and design. |
| 316 | `                                            .foregroundStyle(StamerleeTheme.primaryBlue)` | Sets the foreground color or style. |
| 317 | `                                            .transition(.scale.combined(with: .opacity))` | Applies a SwiftUI modifier to the preceding view. |
| 318 | `                                    }` | Opens or closes a Swift scope or view-builder block. |
| 319 | `                                }` | Opens or closes a Swift scope or view-builder block. |
| 320 | `                                .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 321 | `                                .frame(height: 44)` | Constrains the view size or alignment. |
| 322 | `                                .background(` | Adds a background behind the content. |
| 323 | `                                    Capsule().fill(` | Implements the surrounding screen, camera, or view-builder expression. |
| 324 | `                                        isSelected` | Implements the surrounding screen, camera, or view-builder expression. |
| 325 | `                                            ? StamerleeTheme.primaryBlue.opacity(0.38)` | Implements the surrounding screen, camera, or view-builder expression. |
| 326 | `                                            : Color.white.opacity(0.07)` | Implements the surrounding screen, camera, or view-builder expression. |
| 327 | `                                    )` | Implements the surrounding screen, camera, or view-builder expression. |
| 328 | `                                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 329 | `                                .overlay(` | Draws an additional view above the content. |
| 330 | `                                    Capsule().stroke(` | Implements the surrounding screen, camera, or view-builder expression. |
| 331 | `                                        isSelected` | Implements the surrounding screen, camera, or view-builder expression. |
| 332 | `                                            ? StamerleeTheme.primaryBlue` | Implements the surrounding screen, camera, or view-builder expression. |
| 333 | `                                            : Color.white.opacity(0.12),` | Implements the surrounding screen, camera, or view-builder expression. |
| 334 | `                                        lineWidth: isSelected ? 1.5 : 1` | Implements the surrounding screen, camera, or view-builder expression. |
| 335 | `                                    )` | Implements the surrounding screen, camera, or view-builder expression. |
| 336 | `                                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 337 | `                                .clipShape(Capsule())` | Clips content to a supplied shape. |
| 338 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 339 | `                            .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 340 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 341 | `` | Blank line separating code sections. |
| 342 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 343 | `                    .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 344 | `                    .padding(.top, 8)` | Adds layout spacing around the view. |
| 345 | `                    .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 346 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 347 | `` | Blank line separating code sections. |
| 348 | `                // Anchored CTA` | Comment describing the purpose of the following code. |
| 349 | `                VStack {` | Opens or closes a Swift scope or view-builder block. |
| 350 | `                    PrimaryActionButton(title: "Continue") {` | Opens or closes a Swift scope or view-builder block. |
| 351 | `                        if state.beatBuddySelectedWords.isEmpty {` | Conditionally selects this behavior or view. |
| 352 | `                            state.beatBuddySelectedWords = ["Water", "Coffee"]` | Implements the surrounding screen, camera, or view-builder expression. |
| 353 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 354 | `                        if let onContinue {` | Conditionally uses an optional value when present. |
| 355 | `                            onContinue()` | Implements the surrounding screen, camera, or view-builder expression. |
| 356 | `                        } else {` | Opens or closes a Swift scope or view-builder block. |
| 357 | `                            state.navigate(to: .beatBuddyBPM)` | Implements the surrounding screen, camera, or view-builder expression. |
| 358 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 359 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 360 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 361 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 362 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 363 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 364 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 365 | `        .sensoryFeedback(.selection, trigger: state.beatBuddySelectedWords)` | Adds system haptic feedback driven by a state trigger. |
| 366 | `        .alert("Beat Buddy Words", isPresented: $showInfo) {` | Opens or closes a Swift scope or view-builder block. |
| 367 | `            Button("Got it", role: .cancel) {}` | Creates an interactive button. |
| 368 | `        } message: {` | Opens or closes a Swift scope or view-builder block. |
| 369 | `            Text("These are words you’ve previously stuttered on. Practice them repeatedly with a metronome beat to build smoother, more confident speech.")` | Displays a text label. |
| 370 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 371 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 372 | `` | Blank line separating code sections. |
| 373 | `    private func applyCustomWordCount() {` | Defines a private helper for state, layout, or behavior. |
| 374 | `        let count = min(max(Int(customWordCountText) ?? state.beatBuddyWordCount, 1), allWords.count)` | Declares immutable configuration or local data. |
| 375 | `        state.beatBuddyWordCount = count` | Implements the surrounding screen, camera, or view-builder expression. |
| 376 | `        randomizeWords()` | Implements the surrounding screen, camera, or view-builder expression. |
| 377 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 378 | `` | Blank line separating code sections. |
| 379 | `    private func randomizeWords() {` | Defines a private helper for state, layout, or behavior. |
| 380 | `        let count = min(max(state.beatBuddyWordCount, 1), allWords.count)` | Declares immutable configuration or local data. |
| 381 | `        state.beatBuddySelectedWords = Set(allWords.shuffled().prefix(count))` | Implements the surrounding screen, camera, or view-builder expression. |
| 382 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 383 | `}` | Opens or closes a Swift scope or view-builder block. |
| 384 | `` | Blank line separating code sections. |
| 385 | `// MARK: - 2. Interactive Arc BPM Dial` | Section marker organizing the implementation. |
| 386 | `public struct ArcBPMDialView: View {` | Declares a reusable SwiftUI view. |
| 387 | `    @Binding public var bpm: Int` | Implements the surrounding screen, camera, or view-builder expression. |
| 388 | `    public let minBPM: Int = 60` | Implements the surrounding screen, camera, or view-builder expression. |
| 389 | `    public let maxBPM: Int = 180` | Implements the surrounding screen, camera, or view-builder expression. |
| 390 | `    public let size: CGFloat` | Implements the surrounding screen, camera, or view-builder expression. |
| 391 | `` | Blank line separating code sections. |
| 392 | `    @State private var isDragging: Bool = false` | Stores view-local state managed by SwiftUI. |
| 393 | `` | Blank line separating code sections. |
| 394 | `    public init(bpm: Binding<Int>, size: CGFloat = 240) {` | Initializes the view with state and configuration. |
| 395 | `        self._bpm = bpm` | Implements the surrounding screen, camera, or view-builder expression. |
| 396 | `        self.size = size` | Implements the surrounding screen, camera, or view-builder expression. |
| 397 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 398 | `` | Blank line separating code sections. |
| 399 | `    private var fraction: Double {` | Defines a computed helper view or value. |
| 400 | `        let clamped = min(max(bpm, minBPM), maxBPM)` | Declares immutable configuration or local data. |
| 401 | `        return Double(clamped - minBPM) / Double(maxBPM - minBPM)` | Implements the surrounding screen, camera, or view-builder expression. |
| 402 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 403 | `` | Blank line separating code sections. |
| 404 | `    private var knobAngleDegrees: Double {` | Defines a computed helper view or value. |
| 405 | `        135.0 + fraction * 270.0` | Implements the surrounding screen, camera, or view-builder expression. |
| 406 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 407 | `` | Blank line separating code sections. |
| 408 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 409 | `        let radius = (size - 36) / 2` | Declares immutable configuration or local data. |
| 410 | `        let center = CGPoint(x: size / 2, y: size / 2)` | Declares immutable configuration or local data. |
| 411 | `        let knobRad = knobAngleDegrees * .pi / 180.0` | Declares immutable configuration or local data. |
| 412 | `        let knobX = cos(knobRad) * radius` | Declares immutable configuration or local data. |
| 413 | `        let knobY = sin(knobRad) * radius` | Declares immutable configuration or local data. |
| 414 | `` | Blank line separating code sections. |
| 415 | `        ZStack {` | Opens or closes a Swift scope or view-builder block. |
| 416 | `            // Background Inactive Arc Track` | Comment describing the purpose of the following code. |
| 417 | `            Circle()` | Implements the surrounding screen, camera, or view-builder expression. |
| 418 | `                .trim(from: 0, to: 0.75)` | Applies a SwiftUI modifier to the preceding view. |
| 419 | `                .stroke(` | Applies a SwiftUI modifier to the preceding view. |
| 420 | `                    Color.white.opacity(0.08),` | Implements the surrounding screen, camera, or view-builder expression. |
| 421 | `                    style: StrokeStyle(lineWidth: 16, lineCap: .round)` | Implements the surrounding screen, camera, or view-builder expression. |
| 422 | `                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 423 | `                .rotationEffect(.degrees(135))` | Applies a SwiftUI modifier to the preceding view. |
| 424 | `                .frame(width: size - 36, height: size - 36)` | Constrains the view size or alignment. |
| 425 | `` | Blank line separating code sections. |
| 426 | `            // Active Colored Arc Track` | Comment describing the purpose of the following code. |
| 427 | `            Circle()` | Implements the surrounding screen, camera, or view-builder expression. |
| 428 | `                .trim(from: 0, to: CGFloat(fraction * 0.75))` | Applies a SwiftUI modifier to the preceding view. |
| 429 | `                .stroke(` | Applies a SwiftUI modifier to the preceding view. |
| 430 | `                    LinearGradient(` | Implements the surrounding screen, camera, or view-builder expression. |
| 431 | `                        colors: [` | Implements the surrounding screen, camera, or view-builder expression. |
| 432 | `                            Color(red: 30 / 255, green: 215 / 255, blue: 245 / 255),` | Implements the surrounding screen, camera, or view-builder expression. |
| 433 | `                            StamerleeTheme.primaryBlue` | Implements the surrounding screen, camera, or view-builder expression. |
| 434 | `                        ],` | Implements the surrounding screen, camera, or view-builder expression. |
| 435 | `                        startPoint: .topLeading,` | Implements the surrounding screen, camera, or view-builder expression. |
| 436 | `                        endPoint: .bottomTrailing` | Implements the surrounding screen, camera, or view-builder expression. |
| 437 | `                    ),` | Implements the surrounding screen, camera, or view-builder expression. |
| 438 | `                    style: StrokeStyle(lineWidth: 16, lineCap: .round)` | Implements the surrounding screen, camera, or view-builder expression. |
| 439 | `                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 440 | `                .rotationEffect(.degrees(135))` | Applies a SwiftUI modifier to the preceding view. |
| 441 | `                .frame(width: size - 36, height: size - 36)` | Constrains the view size or alignment. |
| 442 | `                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: fraction)` | Applies a SwiftUI modifier to the preceding view. |
| 443 | `` | Blank line separating code sections. |
| 444 | `            // Glowing Draggable Knob Thumb` | Comment describing the purpose of the following code. |
| 445 | `            Circle()` | Implements the surrounding screen, camera, or view-builder expression. |
| 446 | `                .fill(Color.white)` | Applies a SwiftUI modifier to the preceding view. |
| 447 | `                .frame(width: 28, height: 28)` | Constrains the view size or alignment. |
| 448 | `                .overlay(` | Draws an additional view above the content. |
| 449 | `                    Circle()` | Implements the surrounding screen, camera, or view-builder expression. |
| 450 | `                        .stroke(Color(red: 30 / 255, green: 215 / 255, blue: 245 / 255), lineWidth: 3.5)` | Applies a SwiftUI modifier to the preceding view. |
| 451 | `                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 452 | `                .shadow(` | Adds visual depth with a shadow. |
| 453 | `                    color: Color(red: 30 / 255, green: 215 / 255, blue: 245 / 255).opacity(isDragging ? 0.9 : 0.5),` | Implements the surrounding screen, camera, or view-builder expression. |
| 454 | `                    radius: isDragging ? 12 : 6,` | Implements the surrounding screen, camera, or view-builder expression. |
| 455 | `                    x: 0,` | Implements the surrounding screen, camera, or view-builder expression. |
| 456 | `                    y: 0` | Implements the surrounding screen, camera, or view-builder expression. |
| 457 | `                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 458 | `                .scaleEffect(isDragging ? 1.15 : 1.0)` | Applies a SwiftUI modifier to the preceding view. |
| 459 | `                .offset(x: knobX, y: knobY)` | Applies a SwiftUI modifier to the preceding view. |
| 460 | `                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: knobAngleDegrees)` | Applies a SwiftUI modifier to the preceding view. |
| 461 | `` | Blank line separating code sections. |
| 462 | `            // Center Content (Big BPM value, label, and tempo descriptor - NO beating symbol / animation)` | Comment describing the purpose of the following code. |
| 463 | `            VStack(spacing: 4) {` | Opens or closes a Swift scope or view-builder block. |
| 464 | `                Text("\(bpm)")` | Displays a text label. |
| 465 | `                    .font(.system(size: 56, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 466 | `                    .foregroundStyle(.white)` | Sets the foreground color or style. |
| 467 | `                    .contentTransition(.numericText())` | Applies a SwiftUI modifier to the preceding view. |
| 468 | `` | Blank line separating code sections. |
| 469 | `                Text("BPM")` | Displays a text label. |
| 470 | `                    .font(.system(size: 13, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 471 | `                    .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 472 | `                    .tracking(1.4)` | Applies a SwiftUI modifier to the preceding view. |
| 473 | `` | Blank line separating code sections. |
| 474 | `                Text(tempoDescriptor(for: bpm))` | Displays a text label. |
| 475 | `                    .font(.system(size: 11, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 476 | `                    .foregroundStyle(Color.cyan.opacity(0.85))` | Sets the foreground color or style. |
| 477 | `                    .padding(.top, 2)` | Adds layout spacing around the view. |
| 478 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 479 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 480 | `        .frame(width: size, height: size)` | Constrains the view size or alignment. |
| 481 | `        .contentShape(Circle())` | Applies a SwiftUI modifier to the preceding view. |
| 482 | `        .gesture(` | Applies a SwiftUI modifier to the preceding view. |
| 483 | `            DragGesture(minimumDistance: 0)` | Implements the surrounding screen, camera, or view-builder expression. |
| 484 | `                .onChanged { value in` | Applies a SwiftUI modifier to the preceding view. |
| 485 | `                    isDragging = true` | Implements the surrounding screen, camera, or view-builder expression. |
| 486 | `                    updateAngle(location: value.location, center: center)` | Implements the surrounding screen, camera, or view-builder expression. |
| 487 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 488 | `                .onEnded { _ in` | Applies a SwiftUI modifier to the preceding view. |
| 489 | `                    isDragging = false` | Implements the surrounding screen, camera, or view-builder expression. |
| 490 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 491 | `        )` | Implements the surrounding screen, camera, or view-builder expression. |
| 492 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 493 | `` | Blank line separating code sections. |
| 494 | `    private func updateAngle(location: CGPoint, center: CGPoint) {` | Defines a private helper for state, layout, or behavior. |
| 495 | `        let dx = location.x - center.x` | Declares immutable configuration or local data. |
| 496 | `        let dy = location.y - center.y` | Declares immutable configuration or local data. |
| 497 | `        var deg = atan2(dy, dx) * 180 / .pi` | Declares a computed or mutable value. |
| 498 | `        if deg < 0 { deg += 360 }` | Conditionally selects this behavior or view. |
| 499 | `` | Blank line separating code sections. |
| 500 | `        var adjusted = deg - 135` | Declares a computed or mutable value. |
| 501 | `        if adjusted < 0 { adjusted += 360 }` | Conditionally selects this behavior or view. |
| 502 | `` | Blank line separating code sections. |
| 503 | `        if adjusted <= 270 {` | Conditionally selects this behavior or view. |
| 504 | `            let frac = adjusted / 270.0` | Declares immutable configuration or local data. |
| 505 | `            let newBPM = Int((Double(minBPM) + frac * Double(maxBPM - minBPM)).rounded())` | Declares immutable configuration or local data. |
| 506 | `            if newBPM != bpm {` | Conditionally selects this behavior or view. |
| 507 | `                bpm = min(max(newBPM, minBPM), maxBPM)` | Implements the surrounding screen, camera, or view-builder expression. |
| 508 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 509 | `        } else if adjusted > 270 && adjusted < 315 {` | Opens or closes a Swift scope or view-builder block. |
| 510 | `            if bpm != maxBPM {` | Conditionally selects this behavior or view. |
| 511 | `                bpm = maxBPM` | Implements the surrounding screen, camera, or view-builder expression. |
| 512 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 513 | `        } else {` | Opens or closes a Swift scope or view-builder block. |
| 514 | `            if bpm != minBPM {` | Conditionally selects this behavior or view. |
| 515 | `                bpm = minBPM` | Implements the surrounding screen, camera, or view-builder expression. |
| 516 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 517 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 518 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 519 | `` | Blank line separating code sections. |
| 520 | `    private func tempoDescriptor(for bpm: Int) -> String {` | Defines a private helper for state, layout, or behavior. |
| 521 | `        switch bpm {` | Selects behavior based on the current state or setting. |
| 522 | `        case ..<80: return "Slow & Relaxed"` | Handles one enum or switch case. |
| 523 | `        case 80..<110: return "Steady Flow"` | Handles one enum or switch case. |
| 524 | `        case 110..<140: return "Moderate Pacing"` | Handles one enum or switch case. |
| 525 | `        case 140..<165: return "Brisk Rhythm"` | Handles one enum or switch case. |
| 526 | `        default: return "Fast Tempo"` | Implements the surrounding screen, camera, or view-builder expression. |
| 527 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 528 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 529 | `}` | Opens or closes a Swift scope or view-builder block. |
| 530 | `` | Blank line separating code sections. |
| 531 | `` | Blank line separating code sections. |
| 532 | `// MARK: - 3. Select BPM Screen` | Section marker organizing the implementation. |
| 533 | `public struct BeatBuddyBPMView: View {` | Declares a reusable SwiftUI view. |
| 534 | `    @Bindable public var state: AppState` | Connects the view to the observable AppState for two-way mutation. |
| 535 | `    public var onBack: (() -> Void)? = nil` | Implements the surrounding screen, camera, or view-builder expression. |
| 536 | `    public var onStartPractice: (() -> Void)? = nil` | Implements the surrounding screen, camera, or view-builder expression. |
| 537 | `    @State private var soundEnabled: Bool = true` | Stores view-local state managed by SwiftUI. |
| 538 | `    @State private var vibrationEnabled: Bool = true` | Stores view-local state managed by SwiftUI. |
| 539 | `` | Blank line separating code sections. |
| 540 | `    public init(state: AppState, onBack: (() -> Void)? = nil, onStartPractice: (() -> Void)? = nil) {` | Initializes the view with state and configuration. |
| 541 | `        self.state = state` | Implements the surrounding screen, camera, or view-builder expression. |
| 542 | `        self.onBack = onBack` | Implements the surrounding screen, camera, or view-builder expression. |
| 543 | `        self.onStartPractice = onStartPractice` | Implements the surrounding screen, camera, or view-builder expression. |
| 544 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 545 | `` | Blank line separating code sections. |
| 546 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 547 | `        BeatBuddyShell(state: state, onBack: {` | Opens or closes a Swift scope or view-builder block. |
| 548 | `            if let onBack {` | Conditionally uses an optional value when present. |
| 549 | `                onBack()` | Implements the surrounding screen, camera, or view-builder expression. |
| 550 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 551 | `                state.navigate(to: .beatBuddyWords, forward: false)` | Implements the surrounding screen, camera, or view-builder expression. |
| 552 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 553 | `        }) {` | Opens or closes a Swift scope or view-builder block. |
| 554 | `            VStack(alignment: .leading, spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 555 | `                // Headings` | Comment describing the purpose of the following code. |
| 556 | `                Text("Select BPM")` | Displays a text label. |
| 557 | `                    .font(.system(size: 30, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 558 | `                    .foregroundStyle(StamerleeTheme.textPrimaryDark)` | Sets the foreground color or style. |
| 559 | `                    .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 560 | `                    .padding(.top, 18)` | Adds layout spacing around the view. |
| 561 | `` | Blank line separating code sections. |
| 562 | `                Text("Speak with the steady beat")` | Displays a text label. |
| 563 | `                    .font(.system(size: 14, weight: .regular, design: .rounded))` | Sets typography, size, weight, and design. |
| 564 | `                    .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 565 | `                    .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 566 | `                    .padding(.top, 6)` | Adds layout spacing around the view. |
| 567 | `` | Blank line separating code sections. |
| 568 | `                Spacer(minLength: 24)` | Implements the surrounding screen, camera, or view-builder expression. |
| 569 | `` | Blank line separating code sections. |
| 570 | `                // Arc Dial Centered` | Comment describing the purpose of the following code. |
| 571 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 572 | `                    Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 573 | `                    ArcBPMDialView(bpm: $state.beatBuddyBPM, size: 250)` | Implements the surrounding screen, camera, or view-builder expression. |
| 574 | `                    Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 575 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 576 | `` | Blank line separating code sections. |
| 577 | `                Spacer(minLength: 20)` | Implements the surrounding screen, camera, or view-builder expression. |
| 578 | `` | Blank line separating code sections. |
| 579 | `                // Stepper Buttons (- and +)` | Comment describing the purpose of the following code. |
| 580 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 581 | `                    Button {` | Creates an interactive button. |
| 582 | `                        adjustBPM(by: -5)` | Implements the surrounding screen, camera, or view-builder expression. |
| 583 | `                    } label: {` | Opens or closes a Swift scope or view-builder block. |
| 584 | `                        Image(systemName: "minus")` | Displays an image asset or SF Symbol. |
| 585 | `                            .font(.system(size: 16, weight: .bold))` | Sets typography, size, weight, and design. |
| 586 | `                            .foregroundStyle(.white)` | Sets the foreground color or style. |
| 587 | `                            .frame(width: 44, height: 44)` | Constrains the view size or alignment. |
| 588 | `                            .background(Color.white.opacity(0.08))` | Adds a background behind the content. |
| 589 | `                            .clipShape(Circle())` | Clips content to a supplied shape. |
| 590 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 591 | `` | Blank line separating code sections. |
| 592 | `                    Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 593 | `` | Blank line separating code sections. |
| 594 | `                    Button {` | Creates an interactive button. |
| 595 | `                        adjustBPM(by: 5)` | Implements the surrounding screen, camera, or view-builder expression. |
| 596 | `                    } label: {` | Opens or closes a Swift scope or view-builder block. |
| 597 | `                        Image(systemName: "plus")` | Displays an image asset or SF Symbol. |
| 598 | `                            .font(.system(size: 16, weight: .bold))` | Sets typography, size, weight, and design. |
| 599 | `                            .foregroundStyle(.white)` | Sets the foreground color or style. |
| 600 | `                            .frame(width: 44, height: 44)` | Constrains the view size or alignment. |
| 601 | `                            .background(Color.white.opacity(0.08))` | Adds a background behind the content. |
| 602 | `                            .clipShape(Circle())` | Clips content to a supplied shape. |
| 603 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 604 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 605 | `                .padding(.horizontal, 48)` | Adds layout spacing around the view. |
| 606 | `                .padding(.bottom, 16)` | Adds layout spacing around the view. |
| 607 | `` | Blank line separating code sections. |
| 608 | `                // Sound & Vibration Toggles` | Comment describing the purpose of the following code. |
| 609 | `                HStack(spacing: 12) {` | Opens or closes a Swift scope or view-builder block. |
| 610 | `                    toggleButton(title: "Sound", icon: "speaker.wave.2.fill", isOn: soundEnabled) {` | Opens or closes a Swift scope or view-builder block. |
| 611 | `                        soundEnabled.toggle()` | Implements the surrounding screen, camera, or view-builder expression. |
| 612 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 613 | `                    toggleButton(title: "Vibration", icon: "iphone.radiowaves.left.and.right", isOn: vibrationEnabled) {` | Opens or closes a Swift scope or view-builder block. |
| 614 | `                        vibrationEnabled.toggle()` | Implements the surrounding screen, camera, or view-builder expression. |
| 615 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 616 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 617 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 618 | `                .padding(.bottom, 20)` | Adds layout spacing around the view. |
| 619 | `` | Blank line separating code sections. |
| 620 | `                Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 621 | `` | Blank line separating code sections. |
| 622 | `                // Primary Start Button` | Comment describing the purpose of the following code. |
| 623 | `                VStack {` | Opens or closes a Swift scope or view-builder block. |
| 624 | `                    PrimaryActionButton(title: "▶ Start Metronome") {` | Opens or closes a Swift scope or view-builder block. |
| 625 | `                        if let onStartPractice {` | Conditionally uses an optional value when present. |
| 626 | `                            onStartPractice()` | Implements the surrounding screen, camera, or view-builder expression. |
| 627 | `                        } else {` | Opens or closes a Swift scope or view-builder block. |
| 628 | `                            state.navigate(to: .beatBuddyPractice)` | Implements the surrounding screen, camera, or view-builder expression. |
| 629 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 630 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 631 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 632 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 633 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 634 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 635 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 636 | `        .sensoryFeedback(.selection, trigger: state.beatBuddyBPM)` | Adds system haptic feedback driven by a state trigger. |
| 637 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 638 | `` | Blank line separating code sections. |
| 639 | `    private func adjustBPM(by delta: Int) {` | Defines a private helper for state, layout, or behavior. |
| 640 | `        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {` | Animates the enclosed state mutation. |
| 641 | `            state.beatBuddyBPM = min(max(state.beatBuddyBPM + delta, 60), 180)` | Implements the surrounding screen, camera, or view-builder expression. |
| 642 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 643 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 644 | `` | Blank line separating code sections. |
| 645 | `    private func toggleButton(title: String, icon: String, isOn: Bool, action: @escaping () -> Void) -> some View {` | Defines a private helper for state, layout, or behavior. |
| 646 | `        Button(action: {` | Creates an interactive button. |
| 647 | `            action()` | Implements the surrounding screen, camera, or view-builder expression. |
| 648 | `        }) {` | Opens or closes a Swift scope or view-builder block. |
| 649 | `            HStack(spacing: 8) {` | Opens or closes a Swift scope or view-builder block. |
| 650 | `                Image(systemName: icon)` | Displays an image asset or SF Symbol. |
| 651 | `                    .font(.system(size: 15, weight: .semibold))` | Sets typography, size, weight, and design. |
| 652 | `                Text(title)` | Displays a text label. |
| 653 | `                    .font(.system(size: 14, weight: .semibold, design: .rounded))` | Sets typography, size, weight, and design. |
| 654 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 655 | `            .foregroundStyle(isOn ? .white : StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 656 | `            .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 657 | `            .frame(height: 50)` | Constrains the view size or alignment. |
| 658 | `            .background(isOn ? StamerleeTheme.primaryBlue.opacity(0.38) : Color.white.opacity(0.06), in: Capsule())` | Adds a background behind the content. |
| 659 | `            .overlay(` | Draws an additional view above the content. |
| 660 | `                Capsule().stroke(` | Implements the surrounding screen, camera, or view-builder expression. |
| 661 | `                    isOn ? StamerleeTheme.primaryBlue : Color.white.opacity(0.08),` | Implements the surrounding screen, camera, or view-builder expression. |
| 662 | `                    lineWidth: 1` | Implements the surrounding screen, camera, or view-builder expression. |
| 663 | `                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 664 | `            )` | Implements the surrounding screen, camera, or view-builder expression. |
| 665 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 666 | `        .buttonStyle(.haptic)` | Applies a SwiftUI modifier to the preceding view. |
| 667 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 668 | `}` | Opens or closes a Swift scope or view-builder block. |
| 669 | `` | Blank line separating code sections. |
| 670 | `// MARK: - 4. Practice Session Screen` | Section marker organizing the implementation. |
| 671 | `public struct BeatBuddyPracticeView: View {` | Declares a reusable SwiftUI view. |
| 672 | `    @Bindable public var state: AppState` | Connects the view to the observable AppState for two-way mutation. |
| 673 | `    public var onBack: (() -> Void)? = nil` | Implements the surrounding screen, camera, or view-builder expression. |
| 674 | `    public var onFinish: (() -> Void)? = nil` | Implements the surrounding screen, camera, or view-builder expression. |
| 675 | `    @State private var index = 0` | Stores view-local state managed by SwiftUI. |
| 676 | `` | Blank line separating code sections. |
| 677 | `    public init(state: AppState, onBack: (() -> Void)? = nil, onFinish: (() -> Void)? = nil) {` | Initializes the view with state and configuration. |
| 678 | `        self.state = state` | Implements the surrounding screen, camera, or view-builder expression. |
| 679 | `        self.onBack = onBack` | Implements the surrounding screen, camera, or view-builder expression. |
| 680 | `        self.onFinish = onFinish` | Implements the surrounding screen, camera, or view-builder expression. |
| 681 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 682 | `` | Blank line separating code sections. |
| 683 | `    private var words: [String] {` | Defines a computed helper view or value. |
| 684 | `        return Array(state.beatBuddySelectedWords.isEmpty ? Set(["Water", "Coffee"]) : state.beatBuddySelectedWords)` | Implements the surrounding screen, camera, or view-builder expression. |
| 685 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 686 | `` | Blank line separating code sections. |
| 687 | `    public var body: some View {` | Defines the rendered SwiftUI hierarchy. |
| 688 | `        BeatBuddyShell(state: state, onBack: {` | Opens or closes a Swift scope or view-builder block. |
| 689 | `            if let onBack {` | Conditionally uses an optional value when present. |
| 690 | `                onBack()` | Implements the surrounding screen, camera, or view-builder expression. |
| 691 | `            } else {` | Opens or closes a Swift scope or view-builder block. |
| 692 | `                state.navigate(to: .beatBuddyBPM, forward: false)` | Implements the surrounding screen, camera, or view-builder expression. |
| 693 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 694 | `        }) {` | Opens or closes a Swift scope or view-builder block. |
| 695 | `            VStack(spacing: 0) {` | Opens or closes a Swift scope or view-builder block. |
| 696 | `                // Top Info Bar (Only BPM Badge, no timer, no sound icon, no camera icon)` | Comment describing the purpose of the following code. |
| 697 | `                HStack {` | Opens or closes a Swift scope or view-builder block. |
| 698 | `                    Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 699 | `` | Blank line separating code sections. |
| 700 | `                    // BPM Badge` | Comment describing the purpose of the following code. |
| 701 | `                    HStack(spacing: 6) {` | Opens or closes a Swift scope or view-builder block. |
| 702 | `                        Image(systemName: "metronome.fill")` | Displays an image asset or SF Symbol. |
| 703 | `                            .font(.system(size: 12))` | Sets typography, size, weight, and design. |
| 704 | `                            .foregroundStyle(.cyan)` | Sets the foreground color or style. |
| 705 | `                        Text("\(state.beatBuddyBPM) BPM")` | Displays a text label. |
| 706 | `                            .font(.system(size: 12, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 707 | `                            .foregroundStyle(.white)` | Sets the foreground color or style. |
| 708 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 709 | `                    .padding(.horizontal, 14)` | Adds layout spacing around the view. |
| 710 | `                    .padding(.vertical, 8)` | Adds layout spacing around the view. |
| 711 | `                    .background(Color.white.opacity(0.08), in: Capsule())` | Adds a background behind the content. |
| 712 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 713 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 714 | `                .padding(.top, 12)` | Adds layout spacing around the view. |
| 715 | `` | Blank line separating code sections. |
| 716 | `                Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 717 | `` | Blank line separating code sections. |
| 718 | `                // Center Word Practice Card (Large, prominent, clean)` | Comment describing the purpose of the following code. |
| 719 | `                VStack(spacing: 18) {` | Opens or closes a Swift scope or view-builder block. |
| 720 | `                    Text(words[min(index, words.count - 1)])` | Displays a text label. |
| 721 | `                        .font(.system(size: 20, weight: .medium, design: .rounded))` | Sets typography, size, weight, and design. |
| 722 | `                        .foregroundStyle(StamerleeTheme.textSecondaryDark)` | Sets the foreground color or style. |
| 723 | `` | Blank line separating code sections. |
| 724 | `                    Text(splitWord(words[min(index, words.count - 1)]))` | Displays a text label. |
| 725 | `                        .font(.system(size: 42, weight: .bold, design: .rounded))` | Sets typography, size, weight, and design. |
| 726 | `                        .foregroundStyle(.white)` | Sets the foreground color or style. |
| 727 | `` | Blank line separating code sections. |
| 728 | `                    // Page Indicator Dots` | Comment describing the purpose of the following code. |
| 729 | `                    HStack(spacing: 8) {` | Opens or closes a Swift scope or view-builder block. |
| 730 | `                        ForEach(0..<words.count, id: \.self) { i in` | Creates repeated SwiftUI views from a collection. |
| 731 | `                            Circle()` | Implements the surrounding screen, camera, or view-builder expression. |
| 732 | `                                .fill(i == index ? Color.cyan : Color.white.opacity(0.2))` | Applies a SwiftUI modifier to the preceding view. |
| 733 | `                                .frame(width: i == index ? 8 : 6, height: i == index ? 8 : 6)` | Constrains the view size or alignment. |
| 734 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 735 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 736 | `                    .padding(.top, 6)` | Adds layout spacing around the view. |
| 737 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 738 | `                .frame(maxWidth: .infinity)` | Constrains the view size or alignment. |
| 739 | `                .frame(height: 220)` | Constrains the view size or alignment. |
| 740 | `                .background(` | Adds a background behind the content. |
| 741 | `                    RoundedRectangle(cornerRadius: 26, style: .continuous)` | Implements the surrounding screen, camera, or view-builder expression. |
| 742 | `                        .fill(` | Applies a SwiftUI modifier to the preceding view. |
| 743 | `                            LinearGradient(` | Implements the surrounding screen, camera, or view-builder expression. |
| 744 | `                                colors: [` | Implements the surrounding screen, camera, or view-builder expression. |
| 745 | `                                    Color(red: 25 / 255, green: 40 / 255, blue: 95 / 255),` | Implements the surrounding screen, camera, or view-builder expression. |
| 746 | `                                    Color(red: 18 / 255, green: 22 / 255, blue: 50 / 255)` | Implements the surrounding screen, camera, or view-builder expression. |
| 747 | `                                ],` | Implements the surrounding screen, camera, or view-builder expression. |
| 748 | `                                startPoint: .topLeading,` | Implements the surrounding screen, camera, or view-builder expression. |
| 749 | `                                endPoint: .bottomTrailing` | Implements the surrounding screen, camera, or view-builder expression. |
| 750 | `                            )` | Implements the surrounding screen, camera, or view-builder expression. |
| 751 | `                        )` | Implements the surrounding screen, camera, or view-builder expression. |
| 752 | `                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 753 | `                .overlay(` | Draws an additional view above the content. |
| 754 | `                    RoundedRectangle(cornerRadius: 26, style: .continuous)` | Implements the surrounding screen, camera, or view-builder expression. |
| 755 | `                        .stroke(Color.white.opacity(0.14), lineWidth: 1)` | Applies a SwiftUI modifier to the preceding view. |
| 756 | `                )` | Implements the surrounding screen, camera, or view-builder expression. |
| 757 | `                .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 10)` | Adds visual depth with a shadow. |
| 758 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 759 | `` | Blank line separating code sections. |
| 760 | `                Spacer()` | Implements the surrounding screen, camera, or view-builder expression. |
| 761 | `` | Blank line separating code sections. |
| 762 | `                // Bottom Action Button` | Comment describing the purpose of the following code. |
| 763 | `                VStack {` | Opens or closes a Swift scope or view-builder block. |
| 764 | `                    PrimaryActionButton(title: index + 1 < words.count ? "Next Word" : "Finish Practice") {` | Opens or closes a Swift scope or view-builder block. |
| 765 | `                        if index + 1 < words.count {` | Conditionally selects this behavior or view. |
| 766 | `                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {` | Animates the enclosed state mutation. |
| 767 | `                                index += 1` | Implements the surrounding screen, camera, or view-builder expression. |
| 768 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 769 | `                        } else {` | Opens or closes a Swift scope or view-builder block. |
| 770 | `                            if let onFinish {` | Conditionally uses an optional value when present. |
| 771 | `                                onFinish()` | Implements the surrounding screen, camera, or view-builder expression. |
| 772 | `                            } else {` | Opens or closes a Swift scope or view-builder block. |
| 773 | `                                state.navigate(to: .homeDashboard, forward: false)` | Implements the surrounding screen, camera, or view-builder expression. |
| 774 | `                            }` | Opens or closes a Swift scope or view-builder block. |
| 775 | `                        }` | Opens or closes a Swift scope or view-builder block. |
| 776 | `                    }` | Opens or closes a Swift scope or view-builder block. |
| 777 | `                }` | Opens or closes a Swift scope or view-builder block. |
| 778 | `                .padding(.horizontal, 24)` | Adds layout spacing around the view. |
| 779 | `                .padding(.bottom, 24)` | Adds layout spacing around the view. |
| 780 | `            }` | Opens or closes a Swift scope or view-builder block. |
| 781 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 782 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 783 | `` | Blank line separating code sections. |
| 784 | `    private func splitWord(_ word: String) -> AttributedString {` | Defines a private helper for state, layout, or behavior. |
| 785 | `        var result = AttributedString(word)` | Declares a computed or mutable value. |
| 786 | `        let split = result.index(result.startIndex, offsetByCharacters: max(1, word.count / 2))` | Declares immutable configuration or local data. |
| 787 | `        if split < result.endIndex {` | Conditionally selects this behavior or view. |
| 788 | `            result[split...].foregroundColor = Color.cyan` | Implements the surrounding screen, camera, or view-builder expression. |
| 789 | `        }` | Opens or closes a Swift scope or view-builder block. |
| 790 | `        return result` | Implements the surrounding screen, camera, or view-builder expression. |
| 791 | `    }` | Opens or closes a Swift scope or view-builder block. |
| 792 | `}` | Opens or closes a Swift scope or view-builder block. |

## Recommendations

- Add explicit camera permission-denied and unavailable states, ideally with a Settings link or fallback UI.
- Keep camera session configuration/start/stop in a dedicated actor or serial session queue as the feature grows.
- Disable or debounce completion controls after the first completion event.
- Replace raw Beat Buddy settings with typed values and centralize repeated theme colors.
