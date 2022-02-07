import EssentialFeed
import XCTest

class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load() { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()

        let exp = expectation(description: "Expect load to finish")
        var receivedError: Error?
        sut.load() { result in
            if case let .failure(error) = result {
                receivedError = error
            } else {
                XCTFail("Expected failure and got \(String(describing: result)) instead")
            }
            exp.fulfill()
        }

        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1.0 )
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

}
