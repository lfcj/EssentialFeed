import EssentialFeed
import XCTest

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
    }
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        init(_ localFeed: LocalFeedImage) {
            self.id = localFeed.id
            self.description = localFeed.description
            self.location = localFeed.location
            self.url = localFeed.url
        }

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        do {
            let foundCachedData = try JSONDecoder().decode(Cache.self, from: data)
            completion(.found(feed: foundCachedData.feed.map { $0.local }, timestamp: foundCachedData.timestamp))
        } catch (let error) {
            completion(.failure(error))
        }
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let codableCache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(codableCache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }

}

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()

        setUpEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmtpyOnEmtpyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmtpyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieveAfterInsertingToEmptyCache_retrievesInsertedValues() {
        let sut = makeSUT()
        let insertFeed = uniqueImageFeed().local
        let insertTimestamp = Date()
        let exp = expectation(description: "Wait for cache insertion")

        sut.insert(insertFeed, timestamp: insertTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Got unexpected insertion error \(String(describing: insertionError))")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    
        expect(sut, toRetrieve: .found(feed: insertFeed, timestamp: insertTimestamp))
    }

    func test_retrieveTwice_deliversSameCacheEveryTime() {
        let sut = makeSUT()
        let insertFeed = uniqueImageFeed().local
        let insertTimestamp = Date()
        let exp = expectation(description: "Wait for cache insertion")

        sut.insert(insertFeed, timestamp: insertTimestamp) { insertionError in
            XCTAssertNil(insertionError, "Got unexpected insertion error \(String(describing: insertionError))")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)

        expect(sut, toRetrieveTwice: .found(feed: insertFeed, timestamp: insertTimestamp))
        expect(sut, toRetrieveTwice: .found(feed: insertFeed, timestamp: insertTimestamp))
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let store = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(store, file: file, line: line)
        return store
    }

    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.found(receivedFeed, receivedTimestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(receivedFeed, expectedFeed)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp)
            case (.empty, .empty):
                break
            default:
                XCTFail("Expected two equal results, but got \(receivedResult) and \(expectedResult) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    private func expect(
        _ sut: CodableFeedStore,
        toRetrieveTwice expectedResult: RetrieveCacheFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }

    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store ")
    }

    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
