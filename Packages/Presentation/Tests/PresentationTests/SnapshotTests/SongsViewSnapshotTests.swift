import XCTest
import SwiftUI
import SnapshotTesting
@testable import Presentation
@testable import Domain

final class SongsViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // isRecording = true
    }

    @MainActor
    func testSongsView_withRecentlyPlayed() {
        let viewModel = SongsViewModel.preview(recentlyPlayed: Song.mockList)
        let view = SongsView(
            viewModel: viewModel,
            onSongTap: { _ in },
            onViewAlbum: { _ in }
        )
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
    func testSongsView_emptyState() {
        let viewModel = SongsViewModel.preview()
        let view = SongsView(
            viewModel: viewModel,
            onSongTap: { _ in },
            onViewAlbum: { _ in }
        )
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
    func testSongsView_loadingState() {
        let viewModel = SongsViewModel.preview(state: .loading)
        let view = SongsView(
            viewModel: viewModel,
            onSongTap: { _ in },
            onViewAlbum: { _ in }
        )
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
    func testSongsView_searchResults() {
        let viewModel = SongsViewModel.preview(
            songs: Song.mockList,
            state: .loaded,
            searchQuery: "Queen"
        )
        let view = SongsView(
            viewModel: viewModel,
            onSongTap: { _ in },
            onViewAlbum: { _ in }
        )
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
    func testSongsView_emptySearchResults() {
        let viewModel = SongsViewModel.preview(
            state: .empty,
            searchQuery: "nonexistent"
        )
        let view = SongsView(
            viewModel: viewModel,
            onSongTap: { _ in },
            onViewAlbum: { _ in }
        )
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
