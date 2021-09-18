import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(from: url)
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
        let _ = RemoteFeedLoader(url: URL(string: "https://www.google.com")!, client: client)
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let client = HTTPClientMock()
        let sut = RemoteFeedLoader(url: URL(string: "https://www.another-url.com")!, client: client)
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }

}


