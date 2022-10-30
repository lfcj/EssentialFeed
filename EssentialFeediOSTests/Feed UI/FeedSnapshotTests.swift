@testable import EssentialFeed
import EssentialFeediOS
import XCTest

final class FeedSnapshotTests: XCTestCase {

    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_extraExtraExtraLarge_light")
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_FAILED_IMAGE_extraExtraExtraLarge_light")
    }

    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()

        sut.display(feedWithLoadMoreIndicator())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
    }
}

// MARK: - Helpers

private extension FeedSnapshotTests {

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        trackForMemoryLeaks(controller)
        controller.loadViewIfNeeded()
        return controller
    }

    func emptyFeed() -> [FeedImageCellController] {
        []
    }

    func feedWithContent() -> [ImageStub] {
        [
            ImageStub(
                description: "Awesome place",
                location: "Berlin",
                image: UIImage.make(color: .red)
            ),
            ImageStub(
                description: "Different place",
                location: "London",
                image: UIImage.make(color: .green)
            )
        ]
    }

    func feedWithFailedImageLoading() -> [ImageStub] {
        [
            ImageStub(
                description: "Awesome place",
                location: "Berlin",
                image: nil
            ),
            ImageStub(
                description: "Different place",
                location: "London",
                image: nil
            )
        ]
    }

    func feedWithLoadMoreIndicator() -> [CellController] {
        let stub = feedWithContent().last!
        let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selectionHandler: {})
        stub.controller = cellController
        
        let loadMore = LoadMoreCellController()
        loadMore.display(ResourceLoadingViewModel(isLoading: true))

        return [
            CellController(id: UUID(), cellController),
            CellController(id: UUID(), loadMore)
        ]
    }

}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map { stub in
            let imageCellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selectionHandler: {})
            stub.controller = imageCellController
            stub.didRequestImageData()
            return CellController(id: UUID(), imageCellController)
        }
        display(cells)
    }
}

private final class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    let image: UIImage?
    weak var controller: FeedImageCellController?

    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(location: location, description: description)
        self.image = image
    }

    func didRequestImageData() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))

        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any"))
        }
    }

    func didRequestCancellingImageDataLoad() {}

}
