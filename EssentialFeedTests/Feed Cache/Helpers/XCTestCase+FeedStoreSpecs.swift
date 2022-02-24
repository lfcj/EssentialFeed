import EssentialFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {

    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    @discardableResult
    func insert(
        _ cache: (feed: [LocalFeedImage], timestamp: Date),
        into sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> NSError? {
        let exp = expectation(description: "Wait for cache insertion")

        var receivedInsertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
            receivedInsertionError = insertionError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        return receivedInsertionError  as NSError?
    }

    func expect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: RetrieveCacheFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }

    func expect(
        _ sut: FeedStore,
        toRetrieve expectedResult: RetrieveCacheFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.found(receivedFeed, receivedTimestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(receivedFeed, expectedFeed)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp)
            case (.empty, .empty), (.failure, .failure):
                break
            default:
                XCTFail("Expected two equal results, but got \(receivedResult) and \(expectedResult) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    @discardableResult
    func delete(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
        let exp = expectation(description: "Wait for cache deletion")

        var receivedDeletionError: Error?
        sut.deleteCachedFeed { deletionError in
            receivedDeletionError = deletionError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        return receivedDeletionError  as NSError?
    }

}
