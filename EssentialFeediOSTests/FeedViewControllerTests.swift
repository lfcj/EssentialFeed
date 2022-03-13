import XCTest

final class FeedViewController: UIViewController {

    private var loader: FeedViewControllerTests.LoaderSyp?

    convenience init(loader: FeedViewControllerTests.LoaderSyp) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        loader?.load()
    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSyp()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSyp()
        let sut = FeedViewController(loader: loader)

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    // MARK: - Helpers

    class LoaderSyp {
        private(set) var loadCallCount: Int = 0

        func load() {
            loadCallCount += 1
        }
    }
}
