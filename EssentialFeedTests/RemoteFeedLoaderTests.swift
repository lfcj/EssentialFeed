import XCTest

class RemoteFeedLoader {
    let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func load() {
        client.get(from: URL(string: "https://www.google.com"))
    }
}

protocol HTTPClient {
    func get(from url: URL?)
}

class HTTPClientMock: HTTPClient {
    private(set) var requestedURL: URL?

    func get(from url: URL?) {
        self.requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientMock()
        let _ = RemoteFeedLoader(client: client)
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let client = HTTPClientMock()
        let sut = RemoteFeedLoader(client: client)
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }

}


