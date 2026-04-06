import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public struct Endpoint: Sendable {
    public let baseURL: String
    public let path: String
    public let queryItems: [URLQueryItem]
    public let method: HTTPMethod
    public let headers: [String: String]

    public init(
        baseURL: String = "https://itunes.apple.com",
        path: String,
        queryItems: [URLQueryItem] = [],
        method: HTTPMethod = .get,
        headers: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
        self.method = method
        self.headers = headers
    }

    public var url: URL? {
        var components = URLComponents(string: baseURL)
        components?.path = path
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        return components?.url
    }

    public var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
