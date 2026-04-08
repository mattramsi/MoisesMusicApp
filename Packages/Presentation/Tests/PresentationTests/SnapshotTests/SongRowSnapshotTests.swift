import XCTest
import SwiftUI
import SnapshotTesting
@testable import Presentation
@testable import Domain

final class SongRowSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        isRecording = false
    }

    func testSongRow_default() {
        let view = SongRowView(
            song: .mock,
            onTap: {},
            onLongPress: {}
        )
        .frame(width: 393)
        .background(AppColors.background)

        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 393, height: 80),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }

    func testSongRow_explicit() {
        let explicitSong = Song(
            id: 1,
            trackName: "Explicit Song",
            artistName: "Artist",
            collectionName: "Album",
            artworkUrl100: "",
            trackTimeMillis: 180000,
            isExplicit: true
        )

        let view = SongRowView(
            song: explicitSong,
            onTap: {},
            onLongPress: {}
        )
        .frame(width: 393)
        .background(AppColors.background)

        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 393, height: 80),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }

    func testSongRow_longText() {
        let longTextSong = Song(
            id: 1,
            trackName: "This Is A Very Long Song Title That Should Be Truncated",
            artistName: "This Is A Very Long Artist Name That Should Also Be Truncated",
            collectionName: "This Is A Very Long Album Name That Should Definitely Be Truncated",
            artworkUrl100: "",
            trackTimeMillis: 360000
        )

        let view = SongRowView(
            song: longTextSong,
            onTap: {},
            onLongPress: {}
        )
        .frame(width: 393)
        .background(AppColors.background)

        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 393, height: 80),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }

    func testSongRowSkeleton() {
        let view = SongRowSkeletonView()
            .frame(width: 393)
            .background(AppColors.background)

        assertSnapshot(
            of: view,
            as: .image(
                layout: .fixed(width: 393, height: 80),
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }
}
