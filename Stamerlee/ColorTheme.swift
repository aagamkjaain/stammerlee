import SwiftUI

// MARK: - App Color Theme
/// Curated color palette matching the Stamerlee design system.
public enum StamerleeTheme {
    /// Deep midnight background: #0B0C1E
    public static let backgroundDark = Color(red: 11 / 255, green: 12 / 255, blue: 30 / 255)
    
    /// Slightly lighter navy for cards or overlays
    public static let cardDark = Color(red: 19 / 255, green: 21 / 255, blue: 44 / 255)
    
    /// Light periwinkle / lavender sheet background: #ECEFF9
    public static let sheetBackground = Color(red: 236 / 255, green: 239 / 255, blue: 249 / 255)
    
    /// Pure white for cards and buttons
    public static let cardLight = Color.white
    
    /// Vibrant primary brand blue: #0A84FF
    public static let primaryBlue = Color(red: 10 / 255, green: 132 / 255, blue: 255 / 255)
    
    /// Deep interactive blue for pressed states
    public static let primaryBlueDark = Color(red: 0 / 255, green: 110 / 255, blue: 220 / 255)
    
    /// Accent purple gradient for headline highlights
    public static let accentPurpleLight = Color(red: 192 / 255, green: 132 / 255, blue: 252 / 255)
    public static let accentPurple = Color(red: 167 / 255, green: 139 / 255, blue: 250 / 255)
    
    /// Text colors
    public static let textPrimaryDark = Color.white
    public static let textSecondaryDark = Color(red: 160 / 255, green: 168 / 255, blue: 188 / 255)
    
    public static let textPrimaryLight = Color(red: 22 / 255, green: 24 / 255, blue: 35 / 255)
    public static let textSecondaryLight = Color(red: 110 / 255, green: 115 / 255, blue: 132 / 255)
    
    /// Border & separator colors
    public static let dividerLight = Color(red: 218 / 255, green: 222 / 255, blue: 235 / 255)
    public static let subtleBorder = Color.white.opacity(0.12)
    
    /// Illustration accents
    public static let illustrationLilac = Color(red: 202 / 255, green: 206 / 255, blue: 244 / 255)
    public static let illustrationPurple = Color(red: 147 / 255, green: 140 / 255, blue: 220 / 255)
    public static let illustrationCardBg = Color(red: 24 / 255, green: 30 / 255, blue: 68 / 255)
}

// MARK: - Color Hex Initializer Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// testing 

