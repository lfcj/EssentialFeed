import EssentialFeed
import XCTest

final class RemoteLoaderTests: XCTestCase {

    typealias Result = RemoteLoader<String>.Result
    typealias Error = RemoteLoader<String>.Error

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

        expect(sut, toCompleteWith: failure(Error.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: { _, _ in throw anyNSError() })

        expect(sut, toCompleteWith: failure(Error.invalidData), when: {
            client.complete(withStatusCode: 200, data: anyData())
        })
    }

    func test_load_deliversMappedResource() {
        let (sut, client) = makeSUT(mapper: { data, _ in String(data: data, encoding: .utf8) ?? "error"})

        let expectedResource = "string 1"

        expect(sut, toCompleteWith: Result.success(expectedResource), when: {
            let data = expectedResource.data(using: .utf8)!
            client.complete(withStatusCode: 200, data: Data(expectedResource.utf8) )
        })
    }

    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        var (sut, client): (RemoteLoader?, HTTPClientSpy) = makeSUT()

        var receivedResult: RemoteLoader<String>.Result? = nil
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
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
        client: HTTPClientSpy = HTTPClientSpy(),
        file: StaticString = #filePath,
        line: UInt = #line) -> (RemoteLoader<String>, HTTPClientSpy)
    {
        let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)

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

    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        .failure(error)
    }

    private func expect(
        _ sut: RemoteLoader<String>,
        toCompleteWith expectedResult: RemoteLoader<String>.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line)
    {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
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
