import SwiftUI

// MARK: - Onboarding Step 1 (Screenshot 3: "Small steps, stronger speech")
public struct OnboardingStepOneView: View {
    @Bindable public var state: AppState
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Page Indicators
                PageIndicatorView(totalPages: 2, currentPage: 0)
                    .padding(.top, 12)
                
                // Headings Section
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Small steps,")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.textPrimaryDark)
                        
                        Text("stronger speech")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        StamerleeTheme.accentPurpleLight,
                                        StamerleeTheme.accentPurple
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Text("Stuttering can be tough, but you're not alone. Practice at your own pace, build confidence, and celebrate every step forward with us.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 24)
                
                Spacer()
                
                // Hero Illustration
                OnboardingStepOneIllustration()
                    .padding(.vertical, 10)
                
                Spacer()
                
                // Bottom CTA Button ("Begin")
                VStack {
                    PrimaryActionButton(title: "Begin") {
                        state.navigate(to: .onboarding2)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
        }
    }
}
