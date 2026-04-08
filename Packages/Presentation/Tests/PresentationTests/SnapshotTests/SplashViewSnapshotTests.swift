import XCTest
import SwiftUI
import SnapshotTesting
@testable import Presentation

final class SplashViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSplashView() {
        let view = SplashView()
            .frame(width: 393, height: 852) // iPhone 15 Pro dimensions

        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 393, height: 852),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }
}
