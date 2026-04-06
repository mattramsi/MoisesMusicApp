import Foundation

public protocol GetRecentlyPlayedUseCaseProtocol: Sendable {
    func execute() async throws -> [Song]
}

public struct GetRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol, Sendable {
    private let repository: SongRepository

    public init(repository: SongRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Song] {
        try await repository.getRecentlyPlayed()
    }
}
