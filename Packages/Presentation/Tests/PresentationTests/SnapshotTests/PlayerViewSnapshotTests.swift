import XCTest
import SwiftUI
import SnapshotTesting
@testable import Presentation
@testable import Domain

final class PlayerViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    @MainActor
    func testPlayerView_playing() {
        let viewModel = PlayerViewModel.preview(
            isPlaying: true,
            currentTime: 45,
            duration: 90
        )
        let view = PlayerView(viewModel: viewModel)
            .frame(width: 393, height: 852)

        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 393, height: 852),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }

    @MainActor
    func testPlayerView_paused() {
        let viewModel = PlayerViewModel.preview(
            isPlaying: false,
            currentTime: 30,
            duration: 90
        )
        let view = PlayerView(viewModel: viewModel)
            .frame(width: 393, height: 852)

        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 393, height: 852),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }

    @MainActor
    func testPlayerView_progressStart() {
        let viewModel = PlayerViewModel.preview(
            isPlaying: true,
            currentTime: 0,
            duration: 90
        )
        let view = PlayerView(viewModel: viewModel)
            .frame(width: 393, height: 852)

        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 393, height: 852),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }

    @MainActor
    func testPlayerView_progressEnd() {
        let viewModel = PlayerViewModel.preview(
            isPlaying: false,
            currentTime: 90,
            duration: 90
        )
        let view = PlayerView(viewModel: viewModel)
            .frame(width: 393, height: 852)

        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 393, height: 852),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }
}
