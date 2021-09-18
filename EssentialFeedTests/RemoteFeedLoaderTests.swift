import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://www.google.com"))
    }
}

class HTTPClient {
    static var shared = HTTPClient()

    func get(from url: URL?) {}
}

class HTTPClientMock: HTTPClient {
    private(set) var requestedURL: URL?

    override func get(from url: URL?) {
        self.requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientMock()
        let _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let client = HTTPClientMock()
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }

}


