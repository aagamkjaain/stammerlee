import SwiftUI

// MARK: - Onboarding Step 1 Hero Image
/// Girl with headphones and mic badge (asset catalog: `OnboardingHero1`).
public struct OnboardingStepOneIllustration: View {
    @State private var floatBadge: Bool = false
    
    public init() {}
    
    public var body: some View {
        Image("OnboardingHero1")
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 230)
            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 10)
            .scaleEffect(floatBadge ? 1.015 : 0.985)
            .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: floatBadge)
            .frame(height: 245)
            .accessibilityHidden(true)
            .onAppear {
                floatBadge = true
            }
    }
}

// MARK: - Onboarding Step 2 Hero Image
/// Coach video call card with speech bubble (asset catalog: `OnboardingHero2`).
public struct OnboardingStepTwoIllustration: View {
    @State private var subtleFloat: Bool = false
    
    public init() {}
    
    public var body: some View {
        Image("OnboardingHero2")
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 250)
            .shadow(color: Color.black.opacity(0.38), radius: 22, x: 0, y: 11)
            .offset(y: subtleFloat ? -4 : 4)
            .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: subtleFloat)
            .frame(height: 265)
            .accessibilityHidden(true)
            .onAppear {
                subtleFloat = true
            }
    }
}
