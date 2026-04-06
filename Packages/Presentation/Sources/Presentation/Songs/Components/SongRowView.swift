import SwiftUI
import Domain
import Core

public struct SongRowView: View {
    let song: Song
    let onTap: () -> Void
    let onLongPress: () -> Void

    public init(song: Song, onTap: @escaping () -> Void, onLongPress: @escaping () -> Void = {}) {
        self.song = song
        self.onTap = onTap
        self.onLongPress = onLongPress
    }

    public var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                AsyncImageView(
                    url: song.artworkUrl100,
                    size: AppSpacing.artworkSizeMedium
                )

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    HStack(spacing: AppSpacing.xxs) {
                        Text(song.trackName)
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(1)

                        if song.isExplicit {
                            ExplicitBadge()
                        }
                    }

                    Text(song.artistName)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)

                    Text(song.collectionName)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                        .lineLimit(1)
                }

                Spacer()

                Text(song.formattedDuration)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onLongPress()
                }
        )
    }
}

public struct ExplicitBadge: View {
    public init() {}

    public var body: some View {
        Text("E")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(AppColors.tertiaryText)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(AppColors.tertiaryText.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

public struct SongRowSkeletonView: View {
    public init() {}

    public var body: some View {
        HStack(spacing: AppSpacing.sm) {
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium)
                .fill(AppColors.skeleton)
                .frame(width: AppSpacing.artworkSizeMedium, height: AppSpacing.artworkSizeMedium)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.skeleton)
                    .frame(width: 150, height: 16)

                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.skeleton)
                    .frame(width: 100, height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.skeleton)
                    .frame(width: 80, height: 12)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 4)
                .fill(AppColors.skeleton)
                .frame(width: 35, height: 12)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.xs)
        .shimmer()
    }
}

#Preview {
    VStack(spacing: 0) {
        SongRowView(song: .mock, onTap: {})
        SongRowView(
            song: Song(
                id: 2,
                trackName: "Very Long Song Title That Should Truncate",
                artistName: "Artist Name",
                collectionName: "Album Name",
                artworkUrl100: "",
                trackTimeMillis: 240000,
                isExplicit: true
            ),
            onTap: {}
        )
        SongRowSkeletonView()
    }
    .background(AppColors.background)
}
