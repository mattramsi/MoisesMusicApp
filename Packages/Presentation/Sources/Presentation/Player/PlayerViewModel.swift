import Foundation
import Domain
import Core
import Observation

@Observable
@MainActor
public final class PlayerViewModel {
    public let song: Song
    public private(set) var isPlaying = false
    public private(set) var currentTime: Double = 0
    public private(set) var duration: Double = 0
    public private(set) var isLoading = false

    private let audioPlayer: AudioPlayerService
    private let saveRecentlyPlayedUseCase: any SaveRecentlyPlayedUseCaseProtocol
    private var updateTask: Task<Void, Never>?

    public init(
        song: Song,
        audioPlayer: AudioPlayerService,
        saveRecentlyPlayedUseCase: any SaveRecentlyPlayedUseCaseProtocol
    ) {
        self.song = song
        self.audioPlayer = audioPlayer
        self.saveRecentlyPlayedUseCase = saveRecentlyPlayedUseCase
    }

    public func onAppear() {
        startPlaying()
    }

    public func onDisappear() {
        stopUpdates()
        Task {
            await audioPlayer.stop()
        }
    }

    private func startPlaying() {
        guard let urlString = song.previewUrl, let url = URL(string: urlString) else {
            return
        }

        isLoading = true

        Task {
            await audioPlayer.play(url: url)

            // Save to recently played
            try? await saveRecentlyPlayedUseCase.execute(song)

            isLoading = false
            isPlaying = true
            duration = Double(song.trackTimeMillis) / 1000.0

            startUpdates()
        }
    }

    private func startUpdates() {
        updateTask = Task {
            while !Task.isCancelled {
                let state = await audioPlayer.playbackState
                let time = await audioPlayer.currentTime
                let dur = await audioPlayer.duration

                self.currentTime = time
                if dur > 0 {
                    self.duration = dur
                }
                self.isPlaying = state == .playing

                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    private func stopUpdates() {
        updateTask?.cancel()
        updateTask = nil
    }

    public func togglePlayPause() {
        Task {
            if isPlaying {
                await audioPlayer.pause()
            } else {
                await audioPlayer.resume()
            }
            isPlaying = !isPlaying
        }
    }

    public func skipForward() {
        Task {
            await audioPlayer.skipForward(seconds: 15)
            currentTime = await audioPlayer.currentTime
        }
    }

    public func skipBackward() {
        Task {
            await audioPlayer.skipBackward(seconds: 15)
            currentTime = await audioPlayer.currentTime
        }
    }

    public func seek(to time: Double) {
        Task {
            await audioPlayer.seek(to: time)
            currentTime = time
        }
    }

    public var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    public var formattedCurrentTime: String {
        formatTime(currentTime)
    }

    public var formattedDuration: String {
        formatTime(duration)
    }

    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Preview Support

public extension PlayerViewModel {
    static func preview(
        song: Song = .mock,
        isPlaying: Bool = false,
        currentTime: Double = 30,
        duration: Double = 90
    ) -> PlayerViewModel {
        let viewModel = PlayerViewModel(
            song: song,
            audioPlayer: PreviewAudioPlayer(),
            saveRecentlyPlayedUseCase: PreviewSaveRecentlyPlayedUseCase()
        )
        viewModel.isPlaying = isPlaying
        viewModel.currentTime = currentTime
        viewModel.duration = duration
        return viewModel
    }
}

private final class PreviewAudioPlayer: AudioPlayerService, @unchecked Sendable {
    var currentTime: Double { 0 }
    var duration: Double { 0 }
    var playbackState: PlaybackState { .idle }

    func play(url: URL) async {}
    func pause() async {}
    func resume() async {}
    func stop() async {}
    func seek(to time: Double) async {}
    func skipForward(seconds: Double) async {}
    func skipBackward(seconds: Double) async {}
}

private struct PreviewSaveRecentlyPlayedUseCase: SaveRecentlyPlayedUseCaseProtocol {
    func execute(_ song: Song) async throws {}
}
