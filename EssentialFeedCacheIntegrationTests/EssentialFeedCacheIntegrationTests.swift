import EssentialFeed
import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()

        setUpEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toLoad: [])
    }
        
    func test_load_deliveresItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models

        let saveExp = expectation(description: "Wait for save completion")
        sutToPerformSave.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)

        expect(sutToPerformLoad, toLoad: feed)
    }

    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models

        let saveExp1 = expectation(description: "Wait for save completion")
        sutToPerformFirstSave.save(firstFeed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully")
            saveExp1.fulfill()
        }
        wait(for: [saveExp1], timeout: 1.0)

        let saveExp2 = expectation(description: "Wait for save completion")
        sutToPerformSecondSave.save(latestFeed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully")
            saveExp2.fulfill()
        }
        wait(for: [saveExp2], timeout: 1.0)

        expect(sutToPerformLoad, toLoad: latestFeed)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: { Date() })
        trackForMemoryLeaks(store , file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: FeedLoader, toLoad expectedImageFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, expectedImageFeed, "Expected empty feed")
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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

    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("\(type(of: self)).store ")
    }
}
