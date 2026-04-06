import SwiftUI

public enum AppTypography {
    public static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    public static let title = Font.system(size: 28, weight: .bold, design: .default)
    public static let title2 = Font.system(size: 22, weight: .bold, design: .default)
    public static let title3 = Font.system(size: 20, weight: .semibold, design: .default)

    public static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    public static let subheadline = Font.system(size: 15, weight: .regular, design: .default)

    public static let body = Font.system(size: 17, weight: .regular, design: .default)
    public static let callout = Font.system(size: 16, weight: .regular, design: .default)

    public static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    public static let caption = Font.system(size: 12, weight: .regular, design: .default)
    public static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
}

public extension View {
    func appLargeTitle() -> some View {
        font(AppTypography.largeTitle)
            .foregroundStyle(AppColors.primaryText)
    }

    func appTitle() -> some View {
        font(AppTypography.title)
            .foregroundStyle(AppColors.primaryText)
    }

    func appHeadline() -> some View {
        font(AppTypography.headline)
            .foregroundStyle(AppColors.primaryText)
    }

    func appBody() -> some View {
        font(AppTypography.body)
            .foregroundStyle(AppColors.primaryText)
    }

    func appSubheadline() -> some View {
        font(AppTypography.subheadline)
            .foregroundStyle(AppColors.secondaryText)
    }

    func appCaption() -> some View {
        font(AppTypography.caption)
            .foregroundStyle(AppColors.secondaryText)
    }

    func appFootnote() -> some View {
        font(AppTypography.footnote)
            .foregroundStyle(AppColors.secondaryText)
    }
}
