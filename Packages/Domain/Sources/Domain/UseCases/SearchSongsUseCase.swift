import Foundation

public protocol SearchSongsUseCaseProtocol: Sendable {
    func execute(query: String, offset: Int, limit: Int) async throws -> [Song]
}

public struct SearchSongsUseCase: SearchSongsUseCaseProtocol, Sendable {
    private let repository: SongRepository

    public init(repository: SongRepository) {
        self.repository = repository
    }

    public func execute(query: String, offset: Int = 0, limit: Int = 25) async throws -> [Song] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        return try await repository.searchSongs(query: query, offset: offset, limit: limit)
    }
}
