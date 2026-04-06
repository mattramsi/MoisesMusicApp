import Foundation

public struct iTunesSearchResponse: Decodable, Sendable {
    public let resultCount: Int
    public let results: [iTunesTrackDTO]
}

public struct iTunesTrackDTO: Decodable, Sendable {
    public let trackId: Int?
    public let trackName: String?
    public let artistName: String?
    public let collectionName: String?
    public let artworkUrl100: String?
    public let previewUrl: String?
    public let trackTimeMillis: Int?
    public let collectionId: Int?
    public let trackNumber: Int?
    public let discNumber: Int?
    public let releaseDate: String?
    public let primaryGenreName: String?
    public let trackExplicitness: String?
    public let wrapperType: String?
    public let kind: String?

    public var isExplicit: Bool {
        trackExplicitness == "explicit"
    }
}

public struct iTunesLookupResponse: Decodable, Sendable {
    public let resultCount: Int
    public let results: [iTunesLookupResultDTO]
}

public struct iTunesLookupResultDTO: Decodable, Sendable {
    public let wrapperType: String?
    public let collectionType: String?
    public let collectionId: Int?
    public let collectionName: String?
    public let artistName: String?
    public let artworkUrl100: String?
    public let trackCount: Int?
    public let releaseDate: String?
    public let primaryGenreName: String?
    public let copyright: String?

    // Track fields (when wrapperType is "track")
    public let trackId: Int?
    public let trackName: String?
    public let previewUrl: String?
    public let trackTimeMillis: Int?
    public let trackNumber: Int?
    public let discNumber: Int?
    public let trackExplicitness: String?

    public var isExplicit: Bool {
        trackExplicitness == "explicit"
    }
}
