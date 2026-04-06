import XCTest
@testable import Presentation
@testable import Domain
@testable import Core

@MainActor
final class PlayerViewModelTests: XCTestCase {

    func testInitialState() {
        let viewModel = createViewModel()

        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertEqual(viewModel.currentTime, 0)
        XCTAssertEqual(viewModel.duration, 0)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testTogglePlayPausePausesWhenPlaying() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        mockAudioPlayer.playbackState = .playing
        let viewModel = createViewModel(audioPlayer: mockAudioPlayer)

        // Simulate playing state by calling onAppear and waiting for it to start
        viewModel.onAppear()
        try await Task.sleep(for: .milliseconds(200))

        // Now toggle to pause
        viewModel.togglePlayPause()
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.pauseCallCount, 1)
    }

    func testTogglePlayPauseResumesWhenPaused() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        let viewModel = createViewModel(audioPlayer: mockAudioPlayer)

        // Start fresh (not playing) and toggle to play
        viewModel.togglePlayPause()
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.resumeCallCount, 1)
    }

    func testSkipForward() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        let viewModel = createViewModel(audioPlayer: mockAudioPlayer)

        viewModel.skipForward()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.skipForwardCallCount, 1)
    }

    func testSkipBackward() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        let viewModel = createViewModel(audioPlayer: mockAudioPlayer)

        viewModel.skipBackward()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.skipBackwardCallCount, 1)
    }

    func testSeek() async throws {
        let mockAudioPlayer = MockAudioPlayer()
        let viewModel = createViewModel(audioPlayer: mockAudioPlayer)

        viewModel.seek(to: 30)

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(mockAudioPlayer.seekCallCount, 1)
        XCTAssertEqual(mockAudioPlayer.lastSeekTime, 30)
    }

    func testProgressCalculation() {
        // Using preview to set internal state for testing computed properties
        let viewModel = PlayerViewModel.preview(currentTime: 45, duration: 90)

        XCTAssertEqual(viewModel.progress, 0.5, accuracy: 0.01)
    }

    func testFormattedTime() {
        // Using preview to set internal state for testing computed properties
        let viewModel = PlayerViewModel.preview(currentTime: 65, duration: 180)

        XCTAssertEqual(viewModel.formattedCurrentTime, "1:05")
        XCTAssertEqual(viewModel.formattedDuration, "3:00")
    }

    // MARK: - Helper

    private func createViewModel(audioPlayer: MockAudioPlayer = MockAudioPlayer()) -> PlayerViewModel {
        PlayerViewModel(
            song: .mock,
            audioPlayer: audioPlayer,
            saveRecentlyPlayedUseCase: MockSaveRecentlyPlayedUseCase()
        )
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
