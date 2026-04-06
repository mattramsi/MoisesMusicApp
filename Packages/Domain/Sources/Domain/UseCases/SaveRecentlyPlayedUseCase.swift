import Foundation

public protocol SaveRecentlyPlayedUseCaseProtocol: Sendable {
    func execute(_ song: Song) async throws
}

public struct SaveRecentlyPlayedUseCase: SaveRecentlyPlayedUseCaseProtocol, Sendable {
    private let repository: SongRepository

    public init(repository: SongRepository) {
        self.repository = repository
    }

    public func execute(_ song: Song) async throws {
        try await repository.saveRecentlyPlayed(song)
    }
}
