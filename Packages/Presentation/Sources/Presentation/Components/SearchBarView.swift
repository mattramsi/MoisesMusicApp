import SwiftUI

public struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String
    var onSubmit: () -> Void

    public init(text: Binding<String>, placeholder: String = "Search", onSubmit: @escaping () -> Void = {}) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.secondaryText)
                .font(.system(size: AppSpacing.iconSizeMedium))

            TextField(placeholder, text: $text)
                .foregroundStyle(AppColors.primaryText)
                .font(AppTypography.body)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit(onSubmit)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.secondaryText)
                        .font(.system(size: AppSpacing.iconSizeSmall))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColors.searchBarBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusMedium))
    }
}

#Preview {
    VStack(spacing: 20) {
        SearchBarView(text: .constant(""), placeholder: "Search songs, artists...")
        SearchBarView(text: .constant("Queen"), placeholder: "Search songs, artists...")
    }
    .padding()
    .background(AppColors.background)
}
