import EssentialFeed
import Foundation
import XCTest

class CodableFeedStore: FeedStore {
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

    func retrieve(completion: @escaping RetrievalCompletion) {
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

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let encoder = JSONEncoder()
        let codableCache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(codableCache)
        do {
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
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

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), into: sut)
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieveTwice_deliversSameCacheEveryTime() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), into: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: testSpecificStoreURL(), atomically: true, encoding: .utf8)

        expect(sut, toRetrieve: .failure(anyNSError()))
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: testSpecificStoreURL(), atomically: true, encoding: .utf8)

        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        let firstInsertionError = insert((feed: uniqueImageFeed().local, timestamp: Date()), into: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")

        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((feed: latestFeed, timestamp: latestTimestamp), into: sut)

        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        let insertionError = insert((feed: feed, timestamp: timestamp), into: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }

    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = delete(sut)

        XCTAssertNil(deletionError, "Expected successfully deleting cache")
        expect(sut, toRetrieve: .empty)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((feed: uniqueImageFeed().local, timestamp: Date()), into: sut)

        let deletionError = delete(sut)

        XCTAssertNil(deletionError, "Expected successfully deleting non-empty cache")
        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversEroorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)

        let deletionError = delete(sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }

    // MARK: - Helpers

    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> CodableFeedStore {
        let store = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(store, file: file, line: line)
        return store
    }

    @discardableResult
    private func insert(
        _ cache: (feed: [LocalFeedImage], timestamp: Date),
        into sut: CodableFeedStore,
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

    private func expect(
        _ sut: CodableFeedStore,
        toRetrieveTwice expectedResult: RetrieveCacheFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }

    private func expect(
        _ sut: CodableFeedStore,
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
    private func delete(_ sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
        let exp = expectation(description: "Wait for cache deletion")

        var receivedDeletionError: Error?
        sut.deleteCachedFeed { deletionError in
            receivedDeletionError = deletionError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        return receivedDeletionError  as NSError?
    }


    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("\(type(of: self)).store ")
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

    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
}
