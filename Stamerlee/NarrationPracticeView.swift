import SwiftUI
import AVFoundation

// MARK: - Narration Practice
/// Guided narration practice with a level-specific prompt and analysis result.
public struct NarrationPracticeView: View {
    @Bindable public var state: AppState
    @State private var showAnalysis = false
    @State private var selectedWords: Set<String> = ["Dance", "University"]

    public init(state: AppState) {
        self.state = state
    }

    private var difficulty: String { state.selectedNarrationDifficulty }

    private var prompt: String {
        switch difficulty {
        case "Medium": return "Describe what happened first,\nthen explain what happens next"
        case "Hard": return "Tell a complete story with a beginning,\nmiddle, and ending"
        default: return "Describe yourself and your hobbies"
        }
    }

    public var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()
            if showAnalysis { analysisView } else { practiceView }
        }
    }

    private var practiceView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                BackNavButton { state.navigate(to: .narrationDifficulty, forward: false) }
                Spacer()
                Text("DAF")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(StamerleeTheme.primaryBlueDark)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Text(difficulty)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 22)

            Text(prompt)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(StamerleeTheme.textSecondaryDark)
                .padding(.horizontal, 24)
                .padding(.top, 10)

            SelfieCameraPreview()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 24)
                .padding(.top, 24)

            Text(prompt)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 12)

            Spacer()

            Button {
                complete()
            } label: {
                ZStack {
                    Circle().fill(Color(red: 205 / 255, green: 215 / 255, blue: 245 / 255)).frame(width: 78, height: 78)
                    Circle().fill(StamerleeTheme.backgroundDark).frame(width: 52, height: 52)
                    Image(systemName: "mic.fill").foregroundColor(.white).font(.system(size: 23, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 26)

            PrimaryActionButton(title: "Finish") { complete() }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
    }

    private var wordsList: [String] {
        switch difficulty {
        case "Medium":
            return [
                "Sequence", "Detail", "Beginning", "Next", "Transition", "Flow",
                "Explanation", "Storyline", "Moment", "Remember", "Action", "Context",
                "Pacing", "Natural", "Breathe", "Voice", "Clarity", "Presence"
            ]
        case "Hard":
            return [
                "Narrative", "Character", "Conflict", "Resolution", "Journey", "Perspective",
                "Expression", "Meaning", "Imagination", "Experience", "Articulate", "Emotion",
                "Reflection", "Confidence", "Delivery", "Speaking", "Insight", "Connection"
            ]
        default:
            return [
                "Dance", "University", "Breaking", "Computer", "Arts", "Laptop",
                "Water", "Plants", "Teacher", "Science", "Communication", "Interaction",
                "Story", "People", "Picture", "Sentence", "Practice", "Together"
            ]
        }
    }

    private var scoreText: String {
        switch difficulty {
        case "Hard":
            return "8.1"
        case "Medium":
            return "8.7"
        default:
            return "9.3"
        }
    }

    private var analysisView: some View {
        ExerciseAnalysisSkeletonView(
            scoreText: scoreText,
            maxScoreText: "/ 10",
            wordsList: wordsList,
            selectedWords: $selectedWords,
            onDone: {
                state.navigate(to: .homeDashboard)
            }
        )
    }

    private func complete() {
        state.completedNarrationDifficulties.insert(difficulty)
        withAnimation(.easeInOut(duration: 0.25)) {
            showAnalysis = true
        }
    }
}

private struct SelfieCameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.startSession()
        return view
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {}

    static func dismantleUIView(_ uiView: CameraPreviewView, coordinator: ()) {
        uiView.stopSession()
    }
}

private final class CameraPreviewView: UIView {
    private let session = AVCaptureSession()
    private var isConfigured = false

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    private var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    func startSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.configureAndStart()
                }
            }
        default:
            break
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.stopRunning()
        }
    }

    private func configureAndStart() {
        guard !isConfigured else {
            startRunning()
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .high
        defer {
            session.commitConfiguration()
            isConfigured = true
            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill
            startRunning()
        }

        guard
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: camera),
            session.canAddInput(input)
        else {
            return
        }

        session.addInput(input)
    }

    private func startRunning() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.startRunning()
        }
    }
}

#Preview("Narration Practice") {
    @Previewable @State var state = AppState()

    NarrationPracticeView(state: state)
}
