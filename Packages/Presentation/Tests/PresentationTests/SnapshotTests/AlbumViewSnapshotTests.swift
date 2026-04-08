import XCTest
import SwiftUI
import SnapshotTesting
@testable import Presentation
@testable import Domain

final class AlbumViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    @MainActor
    func testAlbumView_withTracks() {
        let viewModel = AlbumViewModel.preview(
            album: .mock,
            songs: Song.mockList
        )
        let view = NavigationStack {
            AlbumView(
                viewModel: viewModel,
                onSongTap: { _ in }
            )
        }
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
    func testAlbumView_loading() {
        let viewModel = AlbumViewModel.preview(isLoading: true)
        let view = NavigationStack {
            AlbumView(
                viewModel: viewModel,
                onSongTap: { _ in }
            )
        }
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
