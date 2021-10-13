import XCTest
@testable import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestedURL)
        XCTAssertTrue(client.requestURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT(url: URL(string: "https://www.another-url.com")!)
        sut.load()
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(client.requestURLs.count, 1)
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT(url: URL(string: "https://www.another-url.com")!)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestURLs.count, 2)
        XCTAssertNotNil(client.requestedURL)
    }

    // MARK: - Helpers

    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        var requestURLs = [URL]()

        func get(from url: URL) {
            self.requestURLs.append(url)
            self.requestedURL = url
        }
    }

    private func makeSUT(url: URL = URL(string: "https://www.google.com")!, client: HTTPClientSpy = HTTPClientSpy()) -> (RemoteFeedLoader, HTTPClientSpy) {
        (RemoteFeedLoader(url: url, client: client), client)
    }

}


