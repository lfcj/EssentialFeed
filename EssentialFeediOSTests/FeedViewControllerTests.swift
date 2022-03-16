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

    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImageFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)!
        let view1 = sut.simulateFeedImageViewVisible(at: 1)!

        XCTAssertTrue(view0.isShowingImageLoadingIndicator, "Expected loading indicator for first view while loading first image")
        XCTAssertTrue(view1.isShowingImageLoadingIndicator, "Expected loading indicator for second view while loading first image")

        loader.completeImageLoading(at: 0)
        XCTAssertFalse(view0.isShowingImageLoadingIndicator, "Expected not loading indicator for first view when it completes successfully")
        XCTAssertTrue(view1.isShowingImageLoadingIndicator, "Expected not loading indicator state change for second view once first image loading completes succesfully")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertFalse(view0.isShowingImageLoadingIndicator, "Expected not loading indicator state change for first view once second image loading completes with error")
        XCTAssertFalse(view1.isShowingImageLoadingIndicator, "Expected not loading indicator for second view once second image loading completes with error")
    }

    func test_feedImageview_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)!
        let view1 = sut.simulateFeedImageViewVisible(at: 1)!
        XCTAssertEqual(view0.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1.renderedImage, .none, "Expected no image for second view while loading second image")

        let imageData0 = UIImage.make(color: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1.renderedImage, .none, "Expected no image for second view once first image loading completes successfully")

        let imageData1 = UIImage.make(color: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes succesfully")
        XCTAssertEqual(view1.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }

    func test_feedImageViewRetryButton_isvisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)!
        let view1 = sut.simulateFeedImageViewVisible(at: 1)!
        XCTAssertEqual(view0.isShowingRetryAcition, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1.isShowingRetryAcition, false, "Expected no retry action for second view while loading second image")

        let imageData0 = UIImage.make(color: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0.isShowingRetryAcition, false, "Expected no retry action for first view once first image loading completes successfully")
        XCTAssertEqual(view1.isShowingRetryAcition, false, "Expected no retry action state change for second view once first image loading completes successfully")

        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0.isShowingRetryAcition, false, "Expected no retry action state chnage for first view once second image loading completes with error")
        XCTAssertEqual(view1.isShowingRetryAcition, true, "Expected retry action for second view once second image loading completes with error")
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
        private var feedRequests = [(FeedLoader.Result) -> Void]()

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

        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() { cancelCallback() }
        }

        typealias ImageRequestCompletion = (FeedImageDataLoader.Result) -> Void
        var loadedImageURLs: [URL] { imageRequests.map { $0.url } }
        private(set) var cancelledImagesURLs = [URL]()

        private var imageRequests = [(url: URL, completion: ImageRequestCompletion)]()

        func loadImageData(from url: URL, completion: @escaping ImageRequestCompletion) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }

        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            imageRequests[index].completion(.failure(anyNSError()))
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
    var isShowingImageLoadingIndicator: Bool { feedImageContainer.isShimmering }
    var renderedImage: Data? { feedImageView.image?.pngData() }
    var isShowingRetryAcition: Bool { !feedImageRetryButton.isHidden }

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

private extension UIImage {

    static func make(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

}
