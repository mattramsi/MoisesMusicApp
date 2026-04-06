import Foundation
@testable import Core

public final class MockHTTPClient: HTTPClient, @unchecked Sendable {
    public var requestHandler: ((Endpoint) async throws -> Data)?
    public var requestCallCount = 0
    public var lastRequestedEndpoint: Endpoint?

    public init() {}

    public func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        requestCallCount += 1
        lastRequestedEndpoint = endpoint

        guard let handler = requestHandler else {
            throw NetworkError.unknown("No handler configured")
        }

        let data = try await handler(endpoint)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    public func request(_ endpoint: Endpoint) async throws -> Data {
        requestCallCount += 1
        lastRequestedEndpoint = endpoint

        guard let handler = requestHandler else {
            throw NetworkError.unknown("No handler configured")
        }

        return try await handler(endpoint)
    }

    public func setResponse<T: Encodable>(_ response: T) {
        requestHandler = { _ in
            try JSONEncoder().encode(response)
        }
    }

    public func setError(_ error: NetworkError) {
        requestHandler = { _ in
            throw error
        }
    }
}
