import Foundation
import SwiftData
import Domain

@ModelActor
public actor SwiftDataSource: LocalDataSource {
    private static let maxRecentlyPlayed = 20

    public func getRecentlyPlayed() async throws -> [Song] {
        let descriptor = FetchDescriptor<SongEntity>(
            predicate: #Predicate { $0.lastPlayedAt != nil },
            sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
        )

        let entities = try modelContext.fetch(descriptor)
        return entities.prefix(Self.maxRecentlyPlayed).map { $0.toDomain() }
    }

    public func saveRecentlyPlayed(_ song: Song) async throws {
        let trackId = song.id
        let descriptor = FetchDescriptor<SongEntity>(
            predicate: #Predicate { $0.trackId == trackId }
        )

        if let existingEntity = try modelContext.fetch(descriptor).first {
            existingEntity.lastPlayedAt = Date()
        } else {
            let newEntity = SongEntity.from(song, lastPlayedAt: Date())
            modelContext.insert(newEntity)
        }

        try cleanupOldEntries()
        try modelContext.save()
    }

    private func cleanupOldEntries() throws {
        let descriptor = FetchDescriptor<SongEntity>(
            predicate: #Predicate { $0.lastPlayedAt != nil },
            sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
        )

        let allEntities = try modelContext.fetch(descriptor)

        if allEntities.count > Self.maxRecentlyPlayed {
            let entitiesToDelete = allEntities.dropFirst(Self.maxRecentlyPlayed)
            for entity in entitiesToDelete {
                modelContext.delete(entity)
            }
        }
    }
}

public extension ModelContainer {
    static func create() throws -> ModelContainer {
        let schema = Schema([SongEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func createInMemory() throws -> ModelContainer {
        let schema = Schema([SongEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
