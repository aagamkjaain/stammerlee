import SwiftUI

// MARK: - Onboarding Step 2 (Screenshot 4: "Support on your schedule")
public struct OnboardingStepTwoView: View {
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
                // Top Page Indicators + Optional Back Button
                ZStack {
                    PageIndicatorView(totalPages: 2, currentPage: 1)
                    
                    HStack {
                        BackNavButton {
                            state.navigate(to: .onboarding1, forward: false)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)
                
                // Headings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Support on your\nschedule")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .lineSpacing(2)
                    
                    Text("Make time for yourself with simple speech activities designed to help you practice fluency, become more comfortable speaking.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(StamerleeTheme.textSecondaryDark)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 24)
                
                Spacer()
                
                // Hero Illustration (Video Call Coach & Speech Bubble)
                OnboardingStepTwoIllustration()
                    .padding(.vertical, 8)
                
                Spacer()
                
                // Bottom CTA Button ("Continue")
                VStack {
                    PrimaryActionButton(title: "Continue") {
                        state.navigate(to: .challengingSounds)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
        }
    }
}
