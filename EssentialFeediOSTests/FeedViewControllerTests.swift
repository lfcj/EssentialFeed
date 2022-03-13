import EssentialFeed
import XCTest

final class FeedViewController: UITableViewController {

    private var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()

        load()
    }

    @objc private func load() {
        loader?.load() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }

}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_viewDidLoad_hidesLoadingIndicatorOnLoadingCompletion() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading()

        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }

    func test_userInitiatedFeedReload_reloadsFeed() {
        let (sut, loader) = makeSUT()
 
        sut.simulatedUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulatedUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    func test_userInitiatedFeedReload_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.simulatedUserInitiatedFeedReload()

        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }

    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoadingCompletion() {
        let (sut, loader) = makeSUT()

        sut.simulatedUserInitiatedFeedReload()
        loader.completeFeedLoading()

        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }

    // MARK: - Helpers

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }

    class LoaderSpy: FeedLoader {
        var loadCallCount: Int { completions.count }
        private var completions = [(Result) -> Void]()

        func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
            completions.append(completion)
        }

        func completeFeedLoading() {
            completions[0](.success([]))
        }
    }
}

private extension FeedViewController {

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    func simulatedUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

}
private extension UIRefreshControl {

    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }

}
