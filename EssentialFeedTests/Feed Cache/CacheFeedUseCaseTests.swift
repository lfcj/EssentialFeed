import XCTest
import EssentialFeed

class LocalFeedLoader {

    let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }

}
class FeedStore {
    
    private(set) var deleteCachedFeedCallCount = 0

    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }

}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()

        sut.save(items)

        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        return (sut: LocalFeedLoader(store: store), store: store)
    }

    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

}
