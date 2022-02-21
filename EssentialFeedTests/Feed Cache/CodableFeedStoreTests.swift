import EssentialFeed
import XCTest

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }

    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store ")

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        do {
            let foundCachedData = try JSONDecoder().decode(Cache.self, from: data)
            completion(.found(feed: foundCachedData.feed, timestamp: foundCachedData.timestamp))
        } catch (let error) {
            completion(.failure(error))
        }
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }

}

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()

        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store ")
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDown() {
        super.tearDown()

        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store ")
        try? FileManager.default.removeItem(at: storeURL)
    }

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

    func test_retrieveAfterInsertingToEmptyCache_retrievesInsertedValues() {
        let sut = CodableFeedStore()
        let insertFeed = uniqueImageFeed().local
        let insertTimestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")

        sut.insert(insertFeed, timestamp: insertTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Got unexpected insertion error \(String(describing: insertionError))")

            sut.retrieve { result in
                switch result {
                case let .found(foundFeed, retrievedFeedTimestamp):
                    XCTAssertEqual(insertFeed, foundFeed)
                    XCTAssertEqual(insertTimestamp, retrievedFeedTimestamp)
                default:
                    XCTFail("Expected .found result, but got \(result) instead")
                }

                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1)
    }

}
