import SwiftUI
import Domain
import Core

public struct SongRowView: View {
    let song: Song
    let onTap: () -> Void
    let onLongPress: () -> Void
    let showMoreButton: Bool

    public init(
        song: Song,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void = {},
        showMoreButton: Bool = true
    ) {
        self.song = song
        self.onTap = onTap
        self.onLongPress = onLongPress
        self.showMoreButton = showMoreButton
    }

    public var body: some View {
        HStack(spacing: AppSpacing.xs) {
            AsyncImageView(
                url: song.artworkUrl100,
                size: 52
            )

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xxs) {
                    Text(song.trackName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)

                    if song.isExplicit {
                        ExplicitBadge()
                    }
                }

                Text(song.artistName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            if showMoreButton {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onLongPress()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.xs)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
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
    let showMoreButton: Bool

    public init(showMoreButton: Bool = true) {
        self.showMoreButton = showMoreButton
    }

    public var body: some View {
        HStack(spacing: AppSpacing.xs) {
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium)
                .fill(AppColors.skeleton)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.skeleton)
                    .frame(width: 150, height: 16)

                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.skeleton)
                    .frame(width: 100, height: 12)
            }

            Spacer()

            if showMoreButton {
                Circle()
                    .fill(AppColors.skeleton)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(AppSpacing.xs)
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
