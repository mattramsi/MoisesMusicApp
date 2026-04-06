import SwiftUI
import Domain

public struct SongActionSheet: View {
    let song: Song
    let onViewAlbum: () -> Void
    let onDismiss: () -> Void

    public init(song: Song, onViewAlbum: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.song = song
        self.onViewAlbum = onViewAlbum
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: 0) {
            dragHandle

            songInfo
                .padding(.vertical, AppSpacing.lg)

            Divider()
                .background(AppColors.divider)

            actionButtons
                .padding(.vertical, AppSpacing.xs)

            cancelButton
                .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge))
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(AppColors.tertiaryText)
            .frame(width: 36, height: 5)
            .padding(.top, AppSpacing.xs)
    }

    private var songInfo: some View {
        HStack(spacing: AppSpacing.sm) {
            AsyncImageView(
                url: song.artworkUrl100,
                size: AppSpacing.artworkSizeMedium
            )

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(song.trackName)
                    .appHeadline()
                    .lineLimit(1)

                Text(song.artistName)
                    .appSubheadline()
                    .lineLimit(1)

                Text(song.collectionName)
                    .appCaption()
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
    }

    private var actionButtons: some View {
        VStack(spacing: 0) {
            actionButton(
                icon: "music.note.list",
                title: "View Album",
                action: {
                    onDismiss()
                    onViewAlbum()
                }
            )
        }
    }

    private func actionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: AppSpacing.iconSizeMedium))
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: AppSpacing.iconSizeLarge)

                Text(title)
                    .appBody()

                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var cancelButton: some View {
        Button(action: onDismiss) {
            Text("Cancel")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
        }
        .buttonStyle(.plain)
        .background(AppColors.searchBarBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
        .padding(.horizontal, AppSpacing.md)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()

        VStack {
            Spacer()
            SongActionSheet(
                song: .mock,
                onViewAlbum: {},
                onDismiss: {}
            )
        }
    }
}
