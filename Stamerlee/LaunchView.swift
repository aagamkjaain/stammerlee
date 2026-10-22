import SwiftUI

// MARK: - Launch Screen (Screenshot 1)
/// Minimalist brand launch screen with centered "Stamerlee" typography.
public struct LaunchView: View {
    @Bindable public var state: AppState
    
    @State private var logoOpacity: Double = 0.0
    @State private var logoScale: CGFloat = 0.94
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            // Centered Logo Wordmark
            VStack {
                Spacer()
                
                Text("Stamerlee")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryDark)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)
                    .shadow(color: Color.white.opacity(0.15), radius: 16, x: 0, y: 0)
                
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Instant skip on user tap
            state.navigate(to: .login)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }
            
            // Auto transition after 1.8 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                if state.currentScreen == .launch {
                    state.navigate(to: .login)
                }
            }
        }
    }
}
