import SwiftUI
import AVFoundation

// MARK: - Narration Practice
/// Guided narration practice with a level-specific prompt and analysis result.
public struct NarrationPracticeView: View {
    @Bindable public var state: AppState
    @State private var showAnalysis = false
    @State private var selectedSegment = "Prolongations"
    @State private var selectedWords: Set<String> = ["Dance", "University"]

    private let wordsBySegment: [String: [String]] = [
        "Prolongations": ["Dance", "University", "Breaking", "Computer", "Arts", "Laptop"],
        "Blocks": ["Water", "Plants", "Teacher", "Science", "Communication", "Interaction"],
        "Repetitions": ["Story", "People", "Picture", "Sentence", "Practice", "Together"]
    ]

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

    private var analysisView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Analysis")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 24)
            VStack(spacing: 6) {
                Text("YOU SCORED").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("86%").font(.system(size: 52, weight: .bold, design: .rounded)).foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 56)
            .padding(.bottom, 26)
            Text("Choose the words to practice them using Beat Buddy")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(StamerleeTheme.textSecondaryDark)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 14)

            HStack(spacing: 0) {
                ForEach(["Prolongations", "Blocks", "Repetitions"], id: \.self) { segment in
                    Button(segment) {
                        selectedSegment = segment
                        selectedWords = Set(wordsBySegment[segment, default: []].prefix(2))
                    }
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(selectedSegment == segment ? .black : .black.opacity(0.7))
                    .frame(maxWidth: .infinity).frame(height: 34)
                    .background(selectedSegment == segment ? .white : .clear)
                    .clipShape(Capsule())
                }
            }
            .padding(3)
            .background(Color(red: 220 / 255, green: 224 / 255, blue: 245 / 255))
            .clipShape(Capsule())
            .padding(.horizontal, 24)
            .padding(.bottom, 22)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(wordsBySegment[selectedSegment, default: []], id: \.self) { word in
                    Button(word) {
                        if selectedWords.contains(word) { selectedWords.remove(word) } else { selectedWords.insert(word) }
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(selectedWords.contains(word) ? .white : StamerleeTheme.textSecondaryDark)
                    .frame(maxWidth: .infinity).frame(height: 44)
                    .background(selectedWords.contains(word) ? Color(red: 20 / 255, green: 45 / 255, blue: 105 / 255) : Color.white.opacity(0.03))
                    .overlay(Capsule().stroke(selectedWords.contains(word) ? StamerleeTheme.primaryBlue : Color.white.opacity(0.06)))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            PrimaryActionButton(title: "Done") { state.navigate(to: .homeDashboard) }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
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
