import SwiftUI

// MARK: - Login Screen (Screenshot 2)
/// Top dark section with "Stamerlee" branding + bottom sheet with OAuth options.
public struct LoginView: View {
    @Bindable public var state: AppState
    
    @State private var emailInput: String = ""
    @State private var passwordInput: String = ""
    @State private var activeSheet: ActiveSheet? = nil
    
    private enum ActiveSheet: Identifiable {
        case emailSignIn
        case terms
        case privacy
        
        var id: Int { hashValue }
    }
    
    public init(state: AppState) {
        self.state = state
    }
    
    public var body: some View {
        ZStack {
            // Dark Background
            StamerleeTheme.backgroundDark
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Header Branding Area
                VStack {
                    Spacer()
                    
                    Text("Stamerlee")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(StamerleeTheme.textPrimaryDark)
                        .padding(.bottom, 36)
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                
                // Bottom Rounded Sheet ("Get started")
                VStack(alignment: .leading, spacing: 20) {
                    // Header text
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Get started")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(StamerleeTheme.textPrimaryLight)
                        
                        Text("Create an account or continue to start your fluency journey.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(StamerleeTheme.textSecondaryLight)
                            .lineSpacing(2)
                    }
                    .padding(.top, 4)
                    
                    // Social Sign In Buttons
                    VStack(spacing: 12) {
                        // Continue with Apple
                        SocialAuthRow(type: .apple) {
                            handleAuth(provider: "Apple")
                        }
                        
                        // Continue with Google
                        SocialAuthRow(type: .google) {
                            handleAuth(provider: "Google")
                        }
                        
                        // Divider with OR
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(StamerleeTheme.dividerLight)
                                .frame(height: 1)
                            
                            Text("OR")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(StamerleeTheme.textSecondaryLight.opacity(0.8))
                            
                            Rectangle()
                                .fill(StamerleeTheme.dividerLight)
                                .frame(height: 1)
                        }
                        .padding(.vertical, 2)
                        
                        // Continue with Email
                        SocialAuthRow(type: .email) {
                            activeSheet = .emailSignIn
                        }
                    }
                    
                    // Terms and Privacy Footer
                    VStack(spacing: 4) {
                        Text("By continuing, you agree to our")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(StamerleeTheme.textSecondaryLight)
                        
                        HStack(spacing: 4) {
                            Button("Terms of Service") {
                                activeSheet = .terms
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(StamerleeTheme.primaryBlue)
                            .underline()
                            
                            Text("and")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(StamerleeTheme.textSecondaryLight)
                            
                            Button("Privacy Policy") {
                                activeSheet = .privacy
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(StamerleeTheme.primaryBlue)
                            .underline()
                            
                            Text(".")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(StamerleeTheme.textSecondaryLight)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .background(
                    StamerleeTheme.sheetBackground
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 36,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 36,
                                style: .continuous
                            )
                        )
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .sheet(item: $activeSheet) { sheet in
            sheetView(for: sheet)
        }
    }
    
    // MARK: - Auth Handler
    private func handleAuth(provider: String) {
        state.authMethod = provider
        state.isAuthenticated = true
        state.navigate(to: .onboarding1)
    }
    
    // MARK: - Modal Sheets
    @ViewBuilder
    private func sheetView(for sheet: ActiveSheet) -> some View {
        NavigationStack {
            Group {
                switch sheet {
                case .emailSignIn:
                    emailSignInSheet
                case .terms:
                    legalTextSheet(
                        title: "Terms of Service",
                        content: """
                        Welcome to Stamerlee. By using our speech practice application, you agree to these terms:
                        
                        1. Personal Practice: Stamerlee provides personalized fluency and speech training activities.
                        2. Progress & Privacy: Your practice audio is processed with your consent and kept strictly private.
                        3. Respectful Use: All users must adhere to constructive speech health practices.
                        """
                    )
                case .privacy:
                    legalTextSheet(
                        title: "Privacy Policy",
                        content: """
                        At Stamerlee, your privacy is our core priority:
                        
                        1. Zero Audio Selling: We never sell or share your vocal recordings.
                        2. On-Device Processing: Speech patterns and audio analysis occur locally on your device whenever possible.
                        3. Data Security: Your account info is encrypted using industry standard protocols.
                        """
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        activeSheet = nil
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Email Sign In Form Sheet
    private var emailSignInSheet: some View {
        VStack(spacing: 20) {
            Text("Sign in with Email")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(StamerleeTheme.textPrimaryLight)
                .padding(.top, 16)
            
            VStack(spacing: 14) {
                TextField("Email address", text: $emailInput)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(red: 242 / 255, green: 244 / 255, blue: 250 / 255))
                    .cornerRadius(12)
                
                SecureField("Password", text: $passwordInput)
                    .padding()
                    .background(Color(red: 242 / 255, green: 244 / 255, blue: 250 / 255))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
            PrimaryActionButton(title: "Continue") {
                state.userEmail = emailInput.isEmpty ? "user@stamerlee.com" : emailInput
                state.authMethod = "Email"
                state.isAuthenticated = true
                activeSheet = nil
                state.navigate(to: .onboarding1)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
            Spacer()
        }
    }
    
    private func legalTextSheet(title: String, content: String) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryLight)
                
                Text(content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(StamerleeTheme.textSecondaryLight)
                    .lineSpacing(4)
                
                Spacer()
            }
            .padding(24)
        }
    }
}
