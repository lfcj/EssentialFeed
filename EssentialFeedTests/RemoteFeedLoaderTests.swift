import XCTest
@testable import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL() {
        let (sut, client) = makeSUT(url: URL(string: "https://www.another-url.com")!)
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }

    // MARK: - Helpers

    class HTTPClientMock: HTTPClient {
        private(set) var requestedURL: URL?

        func get(from url: URL?) {
            self.requestedURL = url
        }
    }

    func makeSUT(url: URL = URL(string: "https://www.google.com")!, client: HTTPClientMock = HTTPClientMock()) -> (RemoteFeedLoader, HTTPClientMock) {
        (RemoteFeedLoader(url: url, client: client), client)
    }

}


