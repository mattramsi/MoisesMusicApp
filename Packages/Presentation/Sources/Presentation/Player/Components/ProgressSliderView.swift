import SwiftUI

public struct ProgressSliderView: View {
    let currentTime: String
    let duration: String
    @Binding var progress: Double
    let onSeek: (Double) -> Void

    @State private var isDragging = false
    @State private var dragProgress: Double = 0

    public init(
        currentTime: String,
        duration: String,
        progress: Binding<Double>,
        onSeek: @escaping (Double) -> Void
    ) {
        self.currentTime = currentTime
        self.duration = duration
        self._progress = progress
        self.onSeek = onSeek
    }

    public var body: some View {
        VStack(spacing: AppSpacing.xs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.searchBarBackground)
                        .frame(height: 4)

                    // Progress track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.accent)
                        .frame(
                            width: max(0, geometry.size.width * displayProgress),
                            height: 4
                        )

                    // Thumb
                    Circle()
                        .fill(AppColors.primaryText)
                        .frame(width: isDragging ? 16 : 12, height: isDragging ? 16 : 12)
                        .offset(x: max(0, min(geometry.size.width - 12, geometry.size.width * displayProgress - 6)))
                        .animation(.easeInOut(duration: 0.1), value: isDragging)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            let newProgress = max(0, min(1, value.location.x / geometry.size.width))
                            dragProgress = newProgress
                        }
                        .onEnded { value in
                            isDragging = false
                            let finalProgress = max(0, min(1, value.location.x / geometry.size.width))
                            onSeek(finalProgress)
                        }
                )
            }
            .frame(height: 20)

            HStack {
                Text(currentTime)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)

                Spacer()

                Text(duration)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress \(currentTime) of \(duration)")
        .accessibilityValue("\(Int(displayProgress * 100)) percent")
    }

    private var displayProgress: Double {
        isDragging ? dragProgress : progress
    }
}

#Preview {
    VStack(spacing: 40) {
        ProgressSliderView(
            currentTime: "0:30",
            duration: "3:45",
            progress: .constant(0.13),
            onSeek: { _ in }
        )

        ProgressSliderView(
            currentTime: "1:52",
            duration: "3:45",
            progress: .constant(0.5),
            onSeek: { _ in }
        )

        ProgressSliderView(
            currentTime: "3:30",
            duration: "3:45",
            progress: .constant(0.93),
            onSeek: { _ in }
        )
    }
    .padding(AppSpacing.xl)
    .background(AppColors.background)
}
