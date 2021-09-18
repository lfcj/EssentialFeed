import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://www.google.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()

    private init() {}
    var requestedURL: URL?
}
class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        let _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }

}


