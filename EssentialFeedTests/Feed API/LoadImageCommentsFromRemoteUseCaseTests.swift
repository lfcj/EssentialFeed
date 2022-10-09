import XCTest
import EssentialFeed

final class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
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

    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 150, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
        
    }

    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data("Invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            })
        }
    }

    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([]), when: {
                let emptyJSON = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyJSON, at: index)
            })
        }
    }

    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let comment1 = makeItem(
            id: UUID(),
            message: "message 1",
            createdAt: (date: Date(timeIntervalSince1970: 1598627222), iso8601String: "2020-08-28T15:07:02+00:00"),
            username: "user"
        )
        let comment2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (date: Date(timeIntervalSince1970: 1577881882), iso8601String: "2020-01-01T12:31:22+00:00"),
            username: "another user"
        )

        let comments = [comment1.model, comment2.model]
        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(comments), when: {
                let jsonData = makeItemsJSON([comment1.json, comment2.json])
                client.complete(withStatusCode: code, data: jsonData, at: index)
            })
        }
    }

    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        var (sut, client): (RemoteImageCommentsLoader?, HTTPClientSpy) = makeSUT()

        var receivedResult: RemoteImageCommentsLoader.Result? = nil
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
        line: UInt = #line) -> (RemoteImageCommentsLoader, HTTPClientSpy)
    {
        let sut = RemoteImageCommentsLoader(url: url, client: client)

        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)

        return (sut, client)
    }

    private func makeItem(
        id: UUID,
        message: String,
        createdAt dateAndDateString: (date: Date, iso8601String: String),
        username: String
    ) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdDate: dateAndDateString.date, username: username)
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": dateAndDateString.iso8601String,
            "author": [
                "username": username
            ]
        ]

        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }

    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        .failure(error)
    }

    private func expect(
        _ sut: RemoteImageCommentsLoader,
        toCompleteWith expectedResult: RemoteImageCommentsLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line)
    {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
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
