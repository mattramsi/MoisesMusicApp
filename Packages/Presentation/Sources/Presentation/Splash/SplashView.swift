import SwiftUI

public struct SplashView: View {
    public init() {}

    public var body: some View {
        Image("Splash", bundle: .module)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
