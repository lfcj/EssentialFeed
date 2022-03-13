import EssentialFeed
import XCTest

final class FeedViewController: UIViewController {

    private var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        loader?.load() { _ in }
    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (loader, _) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    // MARK: - Helpers

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoaderSpy, FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (loader, sut)
    }

    class LoaderSpy: FeedLoader {
        private(set) var loadCallCount: Int = 0

        func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
            loadCallCount += 1
        }
    }
}
