import SwiftUI
import AVFoundation
import CoreImage
import MetalKit
import simd

// MARK: - Chroma Key Helper & 3D Color Cube Generator
public enum ChromaKeyHelper {
    private static func simdSmoothstep(_ edge0: Float, _ edge1: Float, _ x: Float) -> Float {
        let t = min(max((x - edge0) / (edge1 - edge0), 0.0), 1.0)
        return t * t * (3.0 - 2.0 * t)
    }

    /// Precomputes a 64x64x64 3D RGB color cube mapping green-screen hues to transparent alpha
    /// with smooth edge transitions and green spill suppression.
    public static func makeChromaKeyCubeData(dimension: Int = 64) -> Data {
        var cube = [Float](repeating: 0, count: dimension * dimension * dimension * 4)
        var offset = 0
        let invDim = 1.0 / Float(dimension - 1)
        for z in 0..<dimension {
            let b = Float(z) * invDim
            for y in 0..<dimension {
                let g = Float(y) * invDim
                for x in 0..<dimension {
                    let r = Float(x) * invDim

                    let maxRB = max(r, b)
                    let diff = g - maxRB

                    let edge0: Float = 0.08
                    let edge1: Float = 0.20
                    let alpha: Float = 1.0 - simdSmoothstep(edge0, edge1, diff)

                    // De-spill green reflection near silhouette
                    let newG = min(g, maxRB * 1.05)
                    let cleanG = newG + (g - newG) * alpha

                    // Premultiplied RGBA for Core Image
                    cube[offset] = r * alpha
                    cube[offset + 1] = cleanG * alpha
                    cube[offset + 2] = b * alpha
                    cube[offset + 3] = alpha
                    offset += 4
                }
            }
        }
        return Data(bytes: cube, count: cube.count * MemoryLayout<Float>.size)
    }
}

private let sharedChromaCubeData = ChromaKeyHelper.makeChromaKeyCubeData(dimension: 64)

// MARK: - Chroma Key Metal MTKView
public final class ChromaKeyMetalView: MTKView, MTKViewDelegate {
    private var player: AVPlayer?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var loopObserver: NSObjectProtocol?
    private var commandQueue: MTLCommandQueue?
    private var ciContext: CIContext?
    private var colorCubeFilter: CIFilter?
    private var lastKeyedImage: CIImage?

    public init() {
        let device = MTLCreateSystemDefaultDevice()
        super.init(frame: .zero, device: device)
        self.delegate = self
        self.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.isOpaque = false
        self.layer.isOpaque = false
        self.backgroundColor = .clear
        self.framebufferOnly = false
        self.enableSetNeedsDisplay = false
        self.isPaused = false
        self.preferredFramesPerSecond = 30

        if let device = device {
            self.commandQueue = device.makeCommandQueue()
            self.ciContext = CIContext(mtlDevice: device, options: [.useSoftwareRenderer: false])
        } else {
            self.ciContext = CIContext()
        }

        if let filter = CIFilter(name: "CIColorCube") {
            filter.setValue(64, forKey: "inputCubeDimension")
            filter.setValue(sharedChromaCubeData, forKey: "inputCubeData")
            self.colorCubeFilter = filter
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func loadVideo(named videoName: String) {
        cleanup()

        let url = Bundle.main.url(forResource: videoName, withExtension: "mp4")
            ?? Bundle.main.url(forResource: videoName, withExtension: nil)
            ?? URL(fileURLWithPath: Bundle.main.bundlePath).appendingPathComponent("\(videoName).mp4")

        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        let outputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        let output = AVPlayerItemVideoOutput(pixelBufferAttributes: outputSettings)
        item.add(output)
        self.videoOutput = output

        let avPlayer = AVPlayer(playerItem: item)
        avPlayer.actionAtItemEnd = .none
        self.player = avPlayer

        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak avPlayer] _ in
            avPlayer?.seek(to: .zero)
            avPlayer?.play()
        }

        avPlayer.play()
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    public func draw(in view: MTKView) {
        guard let player = player,
              let currentItem = player.currentItem,
              let videoOutput = videoOutput,
              let colorCubeFilter = colorCubeFilter,
              let ciContext = ciContext,
              let commandQueue = commandQueue else { return }

        let itemTime = currentItem.currentTime()
        if videoOutput.hasNewPixelBuffer(forItemTime: itemTime) {
            if let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil) {
                let inputImage = CIImage(cvPixelBuffer: pixelBuffer)
                colorCubeFilter.setValue(inputImage, forKey: kCIInputImageKey)
                if let output = colorCubeFilter.outputImage {
                    lastKeyedImage = output
                }
            }
        }

        guard let frame = lastKeyedImage,
              let currentDrawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        let drawableSize = view.drawableSize
        guard drawableSize.width > 0 && drawableSize.height > 0 else { return }

        let extent = frame.extent
        let scaleX = drawableSize.width / extent.width
        let scaleY = drawableSize.height / extent.height
        let scale = min(scaleX, scaleY)

        let scaled = frame.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let originX = (drawableSize.width - scaled.extent.width) / 2
        let originY = (drawableSize.height - scaled.extent.height) / 2
        let centered = scaled.transformed(by: CGAffineTransform(translationX: originX, y: originY))

        let bounds = CGRect(origin: .zero, size: drawableSize)
        ciContext.render(
            centered,
            to: currentDrawable.texture,
            commandBuffer: commandBuffer,
            bounds: bounds,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }

    public func pause() {
        player?.pause()
    }

    public func resume() {
        player?.play()
    }

    public func cleanup() {
        if let observer = loopObserver {
            NotificationCenter.default.removeObserver(observer)
            loopObserver = nil
        }
        player?.pause()
        player = nil
        videoOutput = nil
    }

    deinit {
        cleanup()
    }
}

// MARK: - SwiftUI Representable
public struct ChromaKeyVideoView: UIViewRepresentable {
    public let videoName: String

    public init(videoName: String = "prolongedvideo") {
        self.videoName = videoName
    }

    public func makeUIView(context: Context) -> ChromaKeyMetalView {
        let view = ChromaKeyMetalView()
        view.loadVideo(named: videoName)
        return view
    }

    public func updateUIView(_ uiView: ChromaKeyMetalView, context: Context) {}

    public static func dismantleUIView(_ uiView: ChromaKeyMetalView, coordinator: ()) {
        uiView.cleanup()
    }
}

