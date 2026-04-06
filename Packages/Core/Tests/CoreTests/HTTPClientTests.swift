import XCTest
@testable import Core

final class HTTPClientTests: XCTestCase {

    func testEndpointURLConstruction() {
        let endpoint = Endpoint(
            baseURL: "https://itunes.apple.com",
            path: "/search",
            queryItems: [
                URLQueryItem(name: "term", value: "queen"),
                URLQueryItem(name: "media", value: "music")
            ]
        )

        XCTAssertNotNil(endpoint.url)
        XCTAssertEqual(endpoint.url?.host, "itunes.apple.com")
        XCTAssertEqual(endpoint.url?.path, "/search")
        XCTAssertTrue(endpoint.url?.query?.contains("term=queen") ?? false)
        XCTAssertTrue(endpoint.url?.query?.contains("media=music") ?? false)
    }

    func testEndpointURLRequestConstruction() {
        let endpoint = Endpoint(
            path: "/search",
            queryItems: [URLQueryItem(name: "term", value: "test")],
            method: .get,
            headers: ["Accept": "application/json"]
        )

        let request = endpoint.urlRequest

        XCTAssertNotNil(request)
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Accept"), "application/json")
    }

    func testNetworkErrorDescriptions() {
        XCTAssertEqual(NetworkError.invalidURL.localizedDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.invalidResponse.localizedDescription, "Invalid server response")
        XCTAssertEqual(NetworkError.httpError(statusCode: 404).localizedDescription, "HTTP error with status code: 404")
        XCTAssertEqual(NetworkError.decodingError.localizedDescription, "Failed to decode response")
        XCTAssertEqual(NetworkError.noData.localizedDescription, "No data received")
    }

    func testMockHTTPClientSuccess() async throws {
        let mock = MockHTTPClient()
        mock.setResponse(["key": "value"])

        let _: [String: String] = try await mock.request(Endpoint(path: "/test"))

        XCTAssertEqual(mock.requestCallCount, 1)
    }

    func testMockHTTPClientError() async {
        let mock = MockHTTPClient()
        mock.setError(.httpError(statusCode: 500))

        do {
            let _: [String: String] = try await mock.request(Endpoint(path: "/test"))
            XCTFail("Expected error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .httpError(statusCode: 500))
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}
