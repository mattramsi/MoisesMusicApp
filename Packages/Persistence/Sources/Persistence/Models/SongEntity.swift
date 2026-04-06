import Foundation
import SwiftData
import Domain

@Model
public final class SongEntity {
    @Attribute(.unique)
    public var trackId: Int

    public var trackName: String
    public var artistName: String
    public var collectionName: String
    public var artworkUrl100: String
    public var previewUrl: String?
    public var trackTimeMillis: Int
    public var collectionId: Int?
    public var trackNumber: Int?
    public var discNumber: Int?
    public var releaseDate: Date?
    public var primaryGenreName: String?
    public var isExplicit: Bool
    public var lastPlayedAt: Date?
    public var createdAt: Date

    public init(
        trackId: Int,
        trackName: String,
        artistName: String,
        collectionName: String,
        artworkUrl100: String,
        previewUrl: String? = nil,
        trackTimeMillis: Int,
        collectionId: Int? = nil,
        trackNumber: Int? = nil,
        discNumber: Int? = nil,
        releaseDate: Date? = nil,
        primaryGenreName: String? = nil,
        isExplicit: Bool = false,
        lastPlayedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.collectionName = collectionName
        self.artworkUrl100 = artworkUrl100
        self.previewUrl = previewUrl
        self.trackTimeMillis = trackTimeMillis
        self.collectionId = collectionId
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.releaseDate = releaseDate
        self.primaryGenreName = primaryGenreName
        self.isExplicit = isExplicit
        self.lastPlayedAt = lastPlayedAt
        self.createdAt = createdAt
    }

    public func toDomain() -> Song {
        Song(
            id: trackId,
            trackName: trackName,
            artistName: artistName,
            collectionName: collectionName,
            artworkUrl100: artworkUrl100,
            previewUrl: previewUrl,
            trackTimeMillis: trackTimeMillis,
            collectionId: collectionId,
            trackNumber: trackNumber,
            discNumber: discNumber,
            releaseDate: releaseDate,
            primaryGenreName: primaryGenreName,
            isExplicit: isExplicit
        )
    }

    public static func from(_ song: Song, lastPlayedAt: Date? = nil) -> SongEntity {
        SongEntity(
            trackId: song.id,
            trackName: song.trackName,
            artistName: song.artistName,
            collectionName: song.collectionName,
            artworkUrl100: song.artworkUrl100,
            previewUrl: song.previewUrl,
            trackTimeMillis: song.trackTimeMillis,
            collectionId: song.collectionId,
            trackNumber: song.trackNumber,
            discNumber: song.discNumber,
            releaseDate: song.releaseDate,
            primaryGenreName: song.primaryGenreName,
            isExplicit: song.isExplicit,
            lastPlayedAt: lastPlayedAt
        )
    }
}
