import Foundation

public protocol HTTPClient: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
}
