import XCTest
import SwiftUI
import SnapshotTesting
@testable import Presentation

final class SplashViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Set record mode to true to record new snapshots
        // isRecording = true
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
