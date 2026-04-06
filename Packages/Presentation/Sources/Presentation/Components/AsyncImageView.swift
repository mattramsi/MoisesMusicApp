import SwiftUI

public struct AsyncImageView: View {
    let url: String?
    let size: CGFloat
    let cornerRadius: CGFloat

    public init(url: String?, size: CGFloat, cornerRadius: CGFloat = AppSpacing.cornerRadiusMedium) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .empty:
                placeholderView
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                placeholderView
            @unknown default:
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholderView: some View {
        ZStack {
            AppColors.cardBackground
            Image(systemName: "music.note")
                .font(.system(size: size * 0.4))
                .foregroundStyle(AppColors.secondaryText)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AsyncImageView(url: nil, size: 60)
        AsyncImageView(url: "https://invalid-url.com/image.jpg", size: 120)
    }
    .padding()
    .background(AppColors.background)
}
