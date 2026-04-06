import AVFoundation
import Combine

public enum PlaybackState: Equatable, Sendable {
    case idle
    case loading
    case playing
    case paused
    case error(String)
}

public protocol AudioPlayerService: Sendable {
    var currentTime: Double { get async }
    var duration: Double { get async }
    var playbackState: PlaybackState { get async }

    func play(url: URL) async
    func pause() async
    func resume() async
    func stop() async
    func seek(to time: Double) async
    func skipForward(seconds: Double) async
    func skipBackward(seconds: Double) async
}

@MainActor
public final class AudioPlayerServiceImpl: AudioPlayerService {
    private var player: AVPlayer?
    private var timeObserver: Any?

    private var _currentTime: Double = 0
    private var _duration: Double = 0
    private var _playbackState: PlaybackState = .idle

    public nonisolated var currentTime: Double {
        get async {
            await MainActor.run { _currentTime }
        }
    }

    public nonisolated var duration: Double {
        get async {
            await MainActor.run { _duration }
        }
    }

    public nonisolated var playbackState: PlaybackState {
        get async {
            await MainActor.run { _playbackState }
        }
    }

    public init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    public nonisolated func play(url: URL) async {
        await MainActor.run {
            _playbackState = .loading
            stop()

            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)

            addTimeObserver()
            observePlayerItem(playerItem)

            player?.play()
            _playbackState = .playing
        }
    }

    public nonisolated func pause() async {
        await MainActor.run {
            player?.pause()
            _playbackState = .paused
        }
    }

    public nonisolated func resume() async {
        await MainActor.run {
            player?.play()
            _playbackState = .playing
        }
    }

    public nonisolated func stop() async {
        await MainActor.run {
            stopInternal()
        }
    }

    private func stopInternal() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        player?.pause()
        player = nil
        _currentTime = 0
        _duration = 0
        _playbackState = .idle
    }

    private func stop() {
        stopInternal()
    }

    public nonisolated func seek(to time: Double) async {
        await MainActor.run {
            let cmTime = CMTime(seconds: time, preferredTimescale: 600)
            player?.seek(to: cmTime)
            _currentTime = time
        }
    }

    public nonisolated func skipForward(seconds: Double) async {
        await MainActor.run {
            let newTime = min(_currentTime + seconds, _duration)
            let cmTime = CMTime(seconds: newTime, preferredTimescale: 600)
            player?.seek(to: cmTime)
            _currentTime = newTime
        }
    }

    public nonisolated func skipBackward(seconds: Double) async {
        await MainActor.run {
            let newTime = max(_currentTime - seconds, 0)
            let cmTime = CMTime(seconds: newTime, preferredTimescale: 600)
            player?.seek(to: cmTime)
            _currentTime = newTime
        }
    }

    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                self?._currentTime = time.seconds
            }
        }
    }

    private func observePlayerItem(_ item: AVPlayerItem) {
        Task {
            for await duration in item.publisher(for: \.duration).values {
                if duration.isNumeric {
                    self._duration = duration.seconds
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?._playbackState = .paused
                self?._currentTime = 0
            }
        }
    }
}
