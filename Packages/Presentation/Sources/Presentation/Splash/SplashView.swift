import SwiftUI

public struct SplashView: View {
    @State private var isAnimating = false

    public init() {}

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                Image(systemName: "music.note.list")
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(AppColors.accent)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.6)

                Text("Moises Music")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashView()
}
