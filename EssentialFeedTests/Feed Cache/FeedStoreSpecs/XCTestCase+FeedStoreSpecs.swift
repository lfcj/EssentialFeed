import EssentialFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {

    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .empty, file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), into: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), into: sut)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImageFeed().local, Date()), into: sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), into: sut)

        let insertionError = insert((uniqueImageFeed().local, Date()), into: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), into: sut)

        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), into: sut)

        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), into: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), into: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }

    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
    }

}
extension FeedStoreSpecs where Self: XCTestCase {

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
    func deleteCache(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
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
