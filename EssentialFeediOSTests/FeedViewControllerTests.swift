import EssentialFeed
import EssentialFeediOS
import XCTest

class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulatedUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading requests once user initiates a load")

        sut.simulatedUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected a third loading requests once user initiates another load")
    }

    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed successfully")

        sut.simulatedUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed with error")
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulatedUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }

    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])

        sut.simulatedUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }

    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")

        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second view also becomes visible")
    }

    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://url-0.com")!)
        let image1 = makeImage(url: URL(string: "https://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requets until image is not visible")

        sut.simulateFeedImageNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected once cancelled image URL request once first image is not visible anymore")

        sut.simulateFeedImageNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once sencond image is also not visible anymore")
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }

    private func assertThat(
        _ sut: FeedViewController,
        isRendering images: [FeedImage],
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

    class LoaderSpy: FeedLoader, FeedImageDataLoader {

        // MARK: - FeedLoader

        var loadFeedCallCount: Int { feedRequests.count }
        private(set) var cancelledImageURLs = [URL]()
        private var feedRequests = [(Result) -> Void]()

        func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
            feedRequests.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int = 0) {
            feedRequests[index](.failure(anyNSError()))
        }

        private func anyNSError() -> NSError {
            NSError(domain: "any", code: 0, userInfo: nil)
        }

        // MARK: - FeedImageDataLoader

        private(set) var loadedImageURLs = [URL]()

        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }

        func cancelImageDataLoad(from url: URL) {
            cancelledImageURLs.append(url)
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

    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
        feedImageView(at: row) as? FeedImageCell
    }

    func simulateFeedImageNotVisible(at row: Int) {
        let view = simulateFeedImageViewVisible(at: row)

        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
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
