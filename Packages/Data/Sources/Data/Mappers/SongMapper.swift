import Foundation
import Domain

public enum SongMapper {
    nonisolated(unsafe) private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    nonisolated(unsafe) private static let fallbackDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    public static func map(_ dto: iTunesTrackDTO) -> Song? {
        guard
            let trackId = dto.trackId,
            let trackName = dto.trackName,
            let artistName = dto.artistName,
            let artworkUrl100 = dto.artworkUrl100,
            let trackTimeMillis = dto.trackTimeMillis
        else {
            return nil
        }

        let releaseDate: Date?
        if let releaseDateString = dto.releaseDate {
            releaseDate = dateFormatter.date(from: releaseDateString)
                ?? fallbackDateFormatter.date(from: releaseDateString)
        } else {
            releaseDate = nil
        }

        return Song(
            id: trackId,
            trackName: trackName,
            artistName: artistName,
            collectionName: dto.collectionName ?? "Unknown Album",
            artworkUrl100: artworkUrl100,
            previewUrl: dto.previewUrl,
            trackTimeMillis: trackTimeMillis,
            collectionId: dto.collectionId,
            trackNumber: dto.trackNumber,
            discNumber: dto.discNumber,
            releaseDate: releaseDate,
            primaryGenreName: dto.primaryGenreName,
            isExplicit: dto.isExplicit
        )
    }

    public static func map(_ dtos: [iTunesTrackDTO]) -> [Song] {
        dtos.compactMap { map($0) }
    }

    public static func mapLookupResult(_ dto: iTunesLookupResultDTO) -> Song? {
        guard
            dto.wrapperType == "track",
            let trackId = dto.trackId,
            let trackName = dto.trackName,
            let artistName = dto.artistName,
            let artworkUrl100 = dto.artworkUrl100,
            let trackTimeMillis = dto.trackTimeMillis
        else {
            return nil
        }

        let releaseDate: Date?
        if let releaseDateString = dto.releaseDate {
            releaseDate = dateFormatter.date(from: releaseDateString)
                ?? fallbackDateFormatter.date(from: releaseDateString)
        } else {
            releaseDate = nil
        }

        return Song(
            id: trackId,
            trackName: trackName,
            artistName: artistName,
            collectionName: dto.collectionName ?? "Unknown Album",
            artworkUrl100: artworkUrl100,
            previewUrl: dto.previewUrl,
            trackTimeMillis: trackTimeMillis,
            collectionId: dto.collectionId,
            trackNumber: dto.trackNumber,
            discNumber: dto.discNumber,
            releaseDate: releaseDate,
            primaryGenreName: dto.primaryGenreName,
            isExplicit: dto.isExplicit
        )
    }

    public static func mapLookupResults(_ dtos: [iTunesLookupResultDTO]) -> [Song] {
        dtos.compactMap { mapLookupResult($0) }
    }
}

public enum AlbumMapper {
    nonisolated(unsafe) private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    nonisolated(unsafe) private static let fallbackDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    public static func map(_ dto: iTunesLookupResultDTO) -> Album? {
        guard
            dto.wrapperType == "collection",
            let collectionId = dto.collectionId,
            let collectionName = dto.collectionName,
            let artistName = dto.artistName,
            let artworkUrl100 = dto.artworkUrl100,
            let trackCount = dto.trackCount
        else {
            return nil
        }

        let releaseDate: Date?
        if let releaseDateString = dto.releaseDate {
            releaseDate = dateFormatter.date(from: releaseDateString)
                ?? fallbackDateFormatter.date(from: releaseDateString)
        } else {
            releaseDate = nil
        }

        return Album(
            id: collectionId,
            collectionName: collectionName,
            artistName: artistName,
            artworkUrl100: artworkUrl100,
            trackCount: trackCount,
            releaseDate: releaseDate,
            primaryGenreName: dto.primaryGenreName,
            copyright: dto.copyright
        )
    }
}
