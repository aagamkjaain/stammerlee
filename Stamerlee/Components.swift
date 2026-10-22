import SwiftUI

// MARK: - Primary Action Button
/// Vibrant blue pill button used for "Begin" and "Continue" actions across screens.
public struct PrimaryActionButton: View {
    public let title: String
    public let icon: String?
    public let isEnabled: Bool
    public let isLoading: Bool
    public let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    public init(
        title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            guard isEnabled && !isLoading else { return }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                Group {
                    if isEnabled {
                        StamerleeTheme.primaryBlue
                    } else {
                        StamerleeTheme.primaryBlue.opacity(0.4)
                    }
                }
            )
            .clipShape(Capsule())
            .shadow(color: isEnabled ? StamerleeTheme.primaryBlue.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .disabled(!isEnabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Social Auth Button Style
public enum SocialAuthType {
    case apple
    case google
    case email
    
    var title: String {
        switch self {
        case .apple: return "Continue with Apple"
        case .google: return "Continue with Google"
        case .email: return "Continue with Email"
        }
    }
}

// MARK: - Social Auth Button
public struct SocialAuthRow: View {
    public let type: SocialAuthType
    public let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    public init(type: SocialAuthType, action: @escaping () -> Void) {
        self.type = type
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 14) {
                // Leading Icon
                iconView
                    .frame(width: 24, height: 24)
                
                // Title
                Text(type.title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(StamerleeTheme.textPrimaryLight)
                
                Spacer()
                
                // Trailing Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.6))
            }
            .padding(.horizontal, 18)
            .frame(height: 54)
            .background(StamerleeTheme.cardLight)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    @ViewBuilder
    private var iconView: some View {
        switch type {
        case .apple:
            Image(systemName: "applelogo")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
        case .google:
            GoogleLogoIcon()
        case .email:
            Image(systemName: "envelope")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(StamerleeTheme.primaryBlue)
        }
    }
}

// MARK: - Google 'G' Icon
public struct GoogleLogoIcon: View {
    public init() {}
    
    public var body: some View {
        ZStack {
            // Stylized 4-color Google G representation
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 234 / 255, green: 67 / 255, blue: 53 / 255),  // Red
                            Color(red: 251 / 255, green: 188 / 255, blue: 5 / 255), // Yellow
                            Color(red: 52 / 255, green: 168 / 255, blue: 83 / 255),  // Green
                            Color(red: 66 / 255, green: 133 / 255, blue: 244 / 255), // Blue
                            Color(red: 234 / 255, green: 67 / 255, blue: 53 / 255)
                        ]),
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: 19, height: 19)
            
            // Cross bar for 'G'
            Rectangle()
                .fill(Color(red: 66 / 255, green: 133 / 255, blue: 244 / 255))
                .frame(width: 9, height: 3)
                .offset(x: 2, y: 0)
        }
    }
}

// MARK: - Page Indicator
public struct PageIndicatorView: View {
    public let totalPages: Int
    public let currentPage: Int
    
    public init(totalPages: Int = 2, currentPage: Int) {
        self.totalPages = totalPages
        self.currentPage = currentPage
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Back Navigation Button
public struct BackNavButton: View {
    public let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 38, height: 38)
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .accessibilityLabel("Go Back")
    }
}

// MARK: - Option Selection Row (Radio / Checkmark)
public struct OptionSelectRow: View {
    public let option: SoundOption
    public let isSelected: Bool
    public let onSelect: () -> Void
    
    public init(option: SoundOption, isSelected: Bool, onSelect: @escaping () -> Void) {
        self.option = option
        self.isSelected = isSelected
        self.onSelect = onSelect
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onSelect()
        }) {
            HStack(spacing: 12) {
                // Title and optional example subtitle
                VStack(alignment: .leading, spacing: 3) {
                    if let subtitle = option.subtitle {
                        HStack(spacing: 4) {
                            Text(option.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(StamerleeTheme.textPrimaryLight)
                            
                            Text("(\(subtitle))")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(StamerleeTheme.textSecondaryLight)
                        }
                    } else {
                        Text(option.title)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(StamerleeTheme.textPrimaryLight)
                    }
                }
                
                Spacer()
                
                // Custom Radio / Checked Indicator
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(StamerleeTheme.primaryBlue)
                            .frame(width: 22, height: 22)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Circle()
                            .stroke(Color(red: 210 / 255, green: 215 / 255, blue: 228 / 255), lineWidth: 1.8)
                            .frame(width: 22, height: 22)
                    }
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? StamerleeTheme.primaryBlue.opacity(0.06) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
