import Foundation
import Core

public enum iTunesEndpoint {
    case search(term: String, offset: Int, limit: Int)
    case lookup(id: Int, entity: String)

    public var endpoint: Endpoint {
        switch self {
        case .search(let term, let offset, let limit):
            return Endpoint(
                path: "/search",
                queryItems: [
                    URLQueryItem(name: "term", value: term),
                    URLQueryItem(name: "media", value: "music"),
                    URLQueryItem(name: "entity", value: "song"),
                    URLQueryItem(name: "offset", value: String(offset)),
                    URLQueryItem(name: "limit", value: String(limit))
                ]
            )

        case .lookup(let id, let entity):
            return Endpoint(
                path: "/lookup",
                queryItems: [
                    URLQueryItem(name: "id", value: String(id)),
                    URLQueryItem(name: "entity", value: entity)
                ]
            )
        }
    }
}

public protocol iTunesDataSourceProtocol: Sendable {
    func searchSongs(term: String, offset: Int, limit: Int) async throws -> iTunesSearchResponse
    func lookupAlbum(id: Int) async throws -> iTunesLookupResponse
}

public final class iTunesDataSource: iTunesDataSourceProtocol, @unchecked Sendable {
    private let httpClient: HTTPClient

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    public func searchSongs(term: String, offset: Int, limit: Int) async throws -> iTunesSearchResponse {
        let endpoint = iTunesEndpoint.search(term: term, offset: offset, limit: limit).endpoint
        return try await httpClient.request(endpoint)
    }

    public func lookupAlbum(id: Int) async throws -> iTunesLookupResponse {
        let endpoint = iTunesEndpoint.lookup(id: id, entity: "song").endpoint
        return try await httpClient.request(endpoint)
    }
}
