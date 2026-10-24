import SwiftUI
import AVFoundation

private let beatBuddyWords = [
    "Water", "University", "Breaking", "Computer", "Scale", "Laptop",
    "Vinyl", "Desk", "Swift", "Center", "Protocol", "Optional"
]

private struct BeatBuddyShell<Content: View>: View {
    @Bindable var state: AppState
    let content: Content

    init(state: AppState, @ViewBuilder content: () -> Content) {
        self.state = state
        self.content = content()
    }

    var body: some View {
        ZStack {
            StamerleeTheme.backgroundDark.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                BackNavButton {
                    state.navigate(to: .homeDashboard, forward: false)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                content
            }
        }
    }
}

public struct BeatBuddyWordsView: View {
    @Bindable public var state: AppState
    @State private var searchText = ""

    public init(state: AppState) {
        self.state = state
    }

    private var filteredWords: [String] {
        beatBuddyWords.filter { searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }
    }

    public var body: some View {
        BeatBuddyShell(state: state) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Select Words")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                Text("Choose the words you want to practice")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.black)

                    TextField("Search", text: $searchText)
                        .font(.system(size: 17, design: .rounded))
                        .foregroundStyle(.black)
                        .tint(.black)

                    Image(systemName: "mic")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.black.opacity(0.65))
                }
                .padding(.horizontal, 20)
                .frame(height: 64)
                .searchGlassBackground()
                .overlay {
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.black.opacity(0.22), lineWidth: 1)
                }
                .padding(.horizontal, 24)
                .padding(.top, 26)

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                    spacing: 14
                ) {
                    ForEach(filteredWords, id: \.self) { word in
                        Button {
                            if state.beatBuddySelectedWords.contains(word) {
                                state.beatBuddySelectedWords.remove(word)
                            } else {
                                state.beatBuddySelectedWords.insert(word)
                            }

                        } label: {
                            Text(word)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    Capsule().fill(
                                        state.beatBuddySelectedWords.contains(word)
                                            ? StamerleeTheme.primaryBlue.opacity(0.38)
                                            : Color.white.opacity(0.06)
                                    )
                                )
                                .overlay(Capsule().stroke(
                                    state.beatBuddySelectedWords.contains(word)
                                        ? StamerleeTheme.primaryBlue
                                        : Color.clear,
                                    lineWidth: 1
                                ))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Spacer()
                PrimaryActionButton(title: "Done") {
                    state.navigate(to: .beatBuddyBPM)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func searchGlassBackground() -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
        } else {
            background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 14))
        }
    }
}

public struct BeatBuddyBPMView: View {
    @Bindable public var state: AppState
    @State private var soundEnabled = true
    @State private var vibrationEnabled = false

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        BeatBuddyShell(state: state) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Select BPM")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.top, 22)
                Text("Speak with the beat")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(StamerleeTheme.textSecondaryDark)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                VStack(spacing: 5) {
                    Image(systemName: "waveform")
                        .foregroundColor(.cyan)
                    Text("\(state.beatBuddyBPM)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("BPM")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                    Slider(value: Binding(
                        get: { Double(state.beatBuddyBPM) },
                        set: { state.beatBuddyBPM = Int($0.rounded()) }
                    ), in: 60...180, step: 1)
                    .tint(.cyan)
                }
                .padding(24)
                .background(Color.white.opacity(0.06), in: Circle())
                .frame(maxWidth: .infinity)
                .padding(.top, 38)

                PrimaryActionButton(title: "▶ Start Metronome") {
                    state.navigate(to: .beatBuddyPractice)
                }
                .padding(.horizontal, 48)
                .padding(.top, 26)

                HStack(spacing: 12) {
                    toggleButton(title: "Sound", icon: "speaker.wave.2.fill", isOn: soundEnabled) {
                        soundEnabled.toggle()
                    }
                    toggleButton(title: "Vibration", icon: "iphone.radiowaves.left.and.right", isOn: vibrationEnabled) {
                        vibrationEnabled.toggle()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
    }

    private func toggleButton(title: String, icon: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(isOn ? .white : StamerleeTheme.textSecondaryDark)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isOn ? StamerleeTheme.primaryBlue.opacity(0.35) : Color.white.opacity(0.06), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

public struct BeatBuddyPracticeView: View {
    @Bindable public var state: AppState
    @State private var index = 0
    @State private var isCameraEnabled = false

    public init(state: AppState) {
        self.state = state
    }

    private var words: [String] {
        Array(state.beatBuddySelectedWords.isEmpty ? Set(["Water"]) : state.beatBuddySelectedWords)
    }

    public var body: some View {
        BeatBuddyShell(state: state) {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Label("DAF", systemImage: "headphones")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(StamerleeTheme.primaryBlue.opacity(0.45), in: Capsule())

                    Button {
                        isCameraEnabled.toggle()
                    } label: {
                        Label(
                            "Camera",
                            systemImage: isCameraEnabled ? "video.fill" : "video.slash.fill"
                        )
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            isCameraEnabled
                                ? StamerleeTheme.primaryBlue.opacity(0.45)
                                : Color.white.opacity(0.1),
                            in: Capsule()
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isCameraEnabled ? "Turn camera off" : "Turn camera on")
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                Spacer()
                VStack(spacing: 20) {
                    Text(words[index])
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(splitWord(words[index]))
                        .font(.system(size: 27, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .background(
                    LinearGradient(colors: [Color.blue.opacity(0.55), Color.blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .padding(.horizontal, 24)
                Spacer()

                if isCameraEnabled {
                    BeatBuddyCameraPreview()
                        .frame(height: 170)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }

                PrimaryActionButton(title: index + 1 < words.count ? "Next" : "Finish") {
                    if index + 1 < words.count {
                        index += 1
                    } else {
                        state.navigate(to: .homeDashboard, forward: false)
                    }
                }
                .padding(.horizontal, 80)
                .padding(.bottom, 28)
            }
            .animation(.easeInOut(duration: 0.25), value: isCameraEnabled)
        }
    }

    private func splitWord(_ word: String) -> AttributedString {
        var result = AttributedString(word)
        let split = result.index(result.startIndex, offsetByCharacters: max(1, word.count / 2))
        if split < result.endIndex {
            result[split...].foregroundColor = .cyan
        }

        return result
    }
}

private struct BeatBuddyCameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> BeatBuddyCameraView {
        BeatBuddyCameraView()
    }

    func updateUIView(_ uiView: BeatBuddyCameraView, context: Context) {}

    static func dismantleUIView(_ uiView: BeatBuddyCameraView, coordinator: ()) {
        uiView.stopSession()
    }
}

private final class BeatBuddyCameraView: UIView {
    private let session = AVCaptureSession()

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    private var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        previewLayer.videoGravity = .resizeAspectFill
        requestCameraAccessAndStart()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func requestCameraAccessAndStart() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.startSession()
                }
            }
        default:
            break
        }
    }

    private func startSession() {
        guard !session.isRunning,
              let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            return
        }

        session.beginConfiguration()
        session.addInput(input)
        session.commitConfiguration()
        previewLayer.session = session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }
}
