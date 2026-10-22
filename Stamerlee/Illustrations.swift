import SwiftUI

// MARK: - Safe Image Loader
/// Loads the screenshot images from the asset catalog, app bundle, or local project folder.
public struct StamerleeImageLoader {
    public static func loadHeroImage(name: String, fallbackPath: String) -> UIImage? {
        // 1. Try Asset Catalog
        if let image = UIImage(named: name) {
            return image
        }
        
        // 2. Try App Bundle
        if let bundlePath = Bundle.main.path(forResource: name, ofType: "png"),
           let image = UIImage(contentsOfFile: bundlePath) {
            return image
        }
        
        // 3. Try direct name with extension in Bundle
        if let image = UIImage(named: "\(name).png") {
            return image
        }
        
        // 4. Try local disk path (for previews and development)
        if FileManager.default.fileExists(atPath: fallbackPath),
           let image = UIImage(contentsOfFile: fallbackPath) {
            return image
        }
        
        return nil
    }
}

// MARK: - Onboarding Step 1 Hero Image
/// Uses the uploaded screenshot (girl with headphones and mic badge).
public struct OnboardingStepOneIllustration: View {
    @State private var floatBadge: Bool = false
    
    private let primaryFallbackPath = "/Users/user89/Desktop/Screenshot 2026-10-22 at 10.09.21 PM.png"
    
    public init() {}
    
    public var body: some View {
        ZStack {
            if let uiImage = StamerleeImageLoader.loadHeroImage(name: "OnboardingHero1", fallbackPath: primaryFallbackPath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 270)
                    .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
                    .scaleEffect(floatBadge ? 1.015 : 0.985)
                    .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: floatBadge)
            } else {
                // Fallback placeholder with symbol
                ZStack {
                    Circle()
                        .fill(Color(red: 202 / 255, green: 206 / 255, blue: 244 / 255))
                        .frame(width: 220, height: 220)
                    
                    Image(systemName: "headphones")
                        .font(.system(size: 80))
                        .foregroundColor(StamerleeTheme.primaryBlue)
                }
            }
        }
        .frame(height: 290)
        .onAppear {
            floatBadge = true
        }
    }
}

// MARK: - Onboarding Step 2 Hero Image
/// Uses the uploaded screenshot (coach video call card with speech bubble).
public struct OnboardingStepTwoIllustration: View {
    @State private var subtleFloat: Bool = false
    
    private let primaryFallbackPath = "/Users/user89/Desktop/Screenshot 2026-10-22 at 10.09.29 PM.png"
    
    public init() {}
    
    public var body: some View {
        ZStack {
            if let uiImage = StamerleeImageLoader.loadHeroImage(name: "OnboardingHero2", fallbackPath: primaryFallbackPath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 310)
                    .shadow(color: Color.black.opacity(0.38), radius: 24, x: 0, y: 12)
                    .offset(y: subtleFloat ? -4 : 4)
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: subtleFloat)
            } else {
                // Fallback placeholder with symbol
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 24 / 255, green: 30 / 255, blue: 68 / 255))
                        .frame(width: 240, height: 240)
                    
                    Image(systemName: "video.fill")
                        .font(.system(size: 70))
                        .foregroundColor(StamerleeTheme.primaryBlue)
                }
            }
        }
        .frame(height: 330)
        .onAppear {
            subtleFloat = true
        }
    }
}
