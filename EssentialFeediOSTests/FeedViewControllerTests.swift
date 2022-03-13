import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSyp) {}
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSyp()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    // MARK: - Helpers

    class LoaderSyp {
        private(set) var loadCallCount: Int = 0
    }
}
