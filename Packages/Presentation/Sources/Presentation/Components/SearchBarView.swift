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
            Image("ic-search-stroke", bundle: .main)
                .renderingMode(.template)
                .foregroundStyle(AppColors.placeholderText)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(AppColors.placeholderText)
                        .font(AppTypography.body)
                }
                TextField("", text: $text)
                    .foregroundStyle(AppColors.primaryText)
                    .font(AppTypography.body)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit(onSubmit)
            }

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
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
