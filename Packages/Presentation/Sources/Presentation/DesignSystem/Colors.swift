import SwiftUI

public enum AppColors {
    public static let background = Color.black
    public static let secondaryBackground = Color(hex: 0x3A3A3C)
    public static let cardBackground = Color(hex: 0x2C2C2E)
    public static let searchBarBackground = Color.white.opacity(0.1)

    public static let primaryText = Color.white
    public static let secondaryText = Color(hex: 0x8E8E93)
    public static let tertiaryText = Color(hex: 0x636366)
    public static let placeholderText = Color(hex: 0xA8A8A8)

    public static let accent = Color(hex: 0x007AFF)
    public static let accentGreen = Color(hex: 0x32D74B)
    public static let accentRed = Color(hex: 0xFF453A)

    public static let divider = Color(hex: 0x3A3A3C)
    public static let skeleton = Color(hex: 0x3A3A3C)

    // MARK: - Play Button
    public static let playButtonGradientStart = Color.black.opacity(0.9)
    public static let playButtonGradientEnd = Color.gray.opacity(0.6)
    public static let playButtonGlossTop = Color.white.opacity(0.25)
    public static let playButtonGlossMid = Color.white.opacity(0.05)
    public static let playButtonStroke = Color.white.opacity(0.15)
    public static let playButtonShadow = Color.black.opacity(0.5)
}

public extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

public extension ShapeStyle where Self == Color {
    static var appBackground: Color { AppColors.background }
    static var appCardBackground: Color { AppColors.cardBackground }
    static var appAccent: Color { AppColors.accent }
}
