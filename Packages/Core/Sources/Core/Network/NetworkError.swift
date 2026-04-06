import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case noData
    case unknown(String)

    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError:
            return "Failed to decode response"
        case .noData:
            return "No data received"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}
