import XCTest
@testable import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT(url: URL(string: "https://www.another-url.com")!)
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs.count, 1)
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT(url: URL(string: "https://www.another-url.com")!)
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs.count, 2)
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
        
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyJSON)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "a desc", location: "a loc", imageURL: URL(string: "https://another-url.com")!)

        let items = [item1.model, item2.model]

        expect(sut, toCompleteWith: .success(items), when: {
            let jsonData = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: jsonData)
        })
    }

    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        var (sut, client): (RemoteFeedLoader?, HTTPClientSpy) = makeSUT()

        var receivedResult: RemoteFeedLoader.Result? = nil
        sut?.load { result in
            receivedResult = result
        }
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))

        XCTAssertNil(receivedResult)
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://www.google.com")!,
        client: HTTPClientSpy = HTTPClientSpy(),
        file: StaticString = #filePath,
        line: UInt = #line) -> (RemoteFeedLoader, HTTPClientSpy)
    {
        let sut = RemoteFeedLoader(url: url, client: client)

        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)

        return (sut, client)
    }

    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL) -> (model: FeedImage, json: [String: Any])
    {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json: [String: Any] = [
            "id": id.uuidString,
            "description": description,// ?? "null",
            "location": location,// ?? "null",
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }

    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }

    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line)
    {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) and received \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1)
    }

}

