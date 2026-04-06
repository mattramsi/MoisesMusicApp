import XCTest
@testable import Presentation
@testable import Domain
@testable import Core

@MainActor
final class PlayerViewModelTests: XCTestCase {

    func testInitialState() {
        let viewModel = PlayerViewModel(
            song: .mock,
            audioPlayer: MockAudioPlayer(),
            saveRecentlyPlayedUseCase: MockSaveRecentlyPlayedUseCase()
        )

        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.currentTime, 0)
        XCTAssertEqual(viewModel.duration, 0)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testTogglePlayPausePausesWhenPlaying() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        let viewModel = PlayerViewModel(
            song: .mock,
            audioPlayer: mockAudioPlayer,
            saveRecentlyPlayedUseCase: MockSaveRecentlyPlayedUseCase()
        )
        viewModel.isPlaying = true

        viewModel.togglePlayPause()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.pauseCallCount, 1)
    }

    func testTogglePlayPauseResumesWhenPaused() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        let viewModel = PlayerViewModel(
            song: .mock,
            audioPlayer: mockAudioPlayer,
            saveRecentlyPlayedUseCase: MockSaveRecentlyPlayedUseCase()
        )
        viewModel.isPlaying = false

        viewModel.togglePlayPause()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.resumeCallCount, 1)
    }

    func testSkipForward() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        let viewModel = PlayerViewModel(
            song: .mock,
            audioPlayer: mockAudioPlayer,
            saveRecentlyPlayedUseCase: MockSaveRecentlyPlayedUseCase()
        )

        viewModel.skipForward()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.skipForwardCallCount, 1)
    }

    func testSkipBackward() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        let viewModel = PlayerViewModel(
            song: .mock,
            audioPlayer: mockAudioPlayer,
            saveRecentlyPlayedUseCase: MockSaveRecentlyPlayedUseCase()
        )

        viewModel.skipBackward()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.skipBackwardCallCount, 1)
    }

    func testSeek() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        let viewModel = PlayerViewModel(
            song: .mock,
            audioPlayer: mockAudioPlayer,
            saveRecentlyPlayedUseCase: MockSaveRecentlyPlayedUseCase()
        )

        viewModel.seek(to: 30)

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.seekCallCount, 1)
        XCTAssertEqual(mockAudioPlayer.lastSeekTime, 30)
    }

    func testProgressCalculation() {
        let viewModel = PlayerViewModel(
            song: .mock,
            audioPlayer: MockAudioPlayer(),
            saveRecentlyPlayedUseCase: MockSaveRecentlyPlayedUseCase()
        )
        viewModel.currentTime = 45
        viewModel.duration = 90

        XCTAssertEqual(viewModel.progress, 0.5, accuracy: 0.01)
    }

    func testFormattedTime() {
        let viewModel = PlayerViewModel(
            song: .mock,
            audioPlayer: MockAudioPlayer(),
            saveRecentlyPlayedUseCase: MockSaveRecentlyPlayedUseCase()
        )
        viewModel.currentTime = 65
        viewModel.duration = 180

        XCTAssertEqual(viewModel.formattedCurrentTime, "1:05")
        XCTAssertEqual(viewModel.formattedDuration, "3:00")
    }
}

// MARK: - Mocks

final class MockAudioPlayer: AudioPlayerService, @unchecked Sendable {
    var currentTime: Double = 0
    var duration: Double = 0
    var playbackState: PlaybackState = .idle

    var playCallCount = 0
    var pauseCallCount = 0
    var resumeCallCount = 0
    var stopCallCount = 0
    var seekCallCount = 0
    var skipForwardCallCount = 0
    var skipBackwardCallCount = 0
    var lastSeekTime: Double = 0

    func play(url: URL) async {
        playCallCount += 1
        playbackState = .playing
    }

    func pause() async {
        pauseCallCount += 1
        playbackState = .paused
    }

    func resume() async {
        resumeCallCount += 1
        playbackState = .playing
    }

    func stop() async {
        stopCallCount += 1
        playbackState = .idle
    }

    func seek(to time: Double) async {
        seekCallCount += 1
        lastSeekTime = time
        currentTime = time
    }

    func skipForward(seconds: Double) async {
        skipForwardCallCount += 1
        currentTime += seconds
    }

    func skipBackward(seconds: Double) async {
        skipBackwardCallCount += 1
        currentTime = max(0, currentTime - seconds)
    }
}

final class MockSaveRecentlyPlayedUseCase: SaveRecentlyPlayedUseCaseProtocol, @unchecked Sendable {
    var saveCallCount = 0

    func execute(_ song: Song) async throws {
        saveCallCount += 1
    }
}
