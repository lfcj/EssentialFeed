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

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }

        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
        
    }

    // MARK: - Helpers

    private class HTTPClientSpy: HTTPClient {
        private(set) var requestedURL: URL?

        private var messages = [(url: URL, completion: (Error) -> Void)]()

        var requestURLs: [URL] {
            messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url: url, completion: completion))
            self.requestedURL = url
        }
    
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }

    private func makeSUT(url: URL = URL(string: "https://www.google.com")!, client: HTTPClientSpy = HTTPClientSpy()) -> (RemoteFeedLoader, HTTPClientSpy) {
        (RemoteFeedLoader(url: url, client: client), client)
    }

}


