import EssentialFeed
import XCTest

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmtpyOnEmtpyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, but got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    func test_retrieve_hasNoSideEffectsOnEmtpyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty results when calling retrieve twice, but got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1)
    }

}
