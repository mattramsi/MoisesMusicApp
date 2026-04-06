import Foundation

public protocol LocalDataSource: Sendable {
    func getRecentlyPlayed() async throws -> [Song]
    func saveRecentlyPlayed(_ song: Song) async throws
}
