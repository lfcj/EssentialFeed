import EssentialFeed
import EssentialFeediOS
import XCTest

class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulatedUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading requests once user initiates a load")

        sut.simulatedUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading requests once user initiates another load")
    }

    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")

        sut.simulatedUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, hasViewsConfiguredFor: [])

        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, hasViewsConfiguredFor: [image0])

        sut.simulatedUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, hasViewsConfiguredFor: [image0, image1, image2, image3])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }

    private func assertThat(
        _ sut: FeedViewController,
        hasViewsConfiguredFor images: [FeedImage],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), images.count)
        images.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }

    private func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int = 0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let view = sut.feedImageView(at: index) as? FeedImageCell
        XCTAssertNotNil(view)
        XCTAssertEqual(view?.isShowingLocation, image.location != nil, file: file, line: line)
        XCTAssertEqual(view?.locationText, image.location, file: file, line: line)
        XCTAssertEqual(view?.descriptionText, image.description, file: file, line: line)
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "www.any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    private func anyURL() -> URL {
        URL(string: "www.any-url.com")!
    }

    class LoaderSpy: FeedLoader {
        var loadCallCount: Int { completions.count }
        private var completions = [(Result) -> Void]()

        func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
            completions.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            completions[index](.success(feed))
        }
    }
}

private extension FeedViewController {

    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    private var feedImagesSection: Int { 0 }

    func simulatedUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImagesSection)
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return dataSource?.tableView(tableView, cellForRowAt: index)
    }

}

private extension FeedImageCell {

    var isShowingLocation: Bool { !locationContainer.isHidden }
    var locationText: String? { locationLabel.text }
    var descriptionText: String? { descriptionLabel.text }

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
