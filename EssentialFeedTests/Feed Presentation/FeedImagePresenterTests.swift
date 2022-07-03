import EssentialFeed
import XCTest

struct FeedImageViewModel<Image> {
    let isLocationContainerHidden: Bool
    let location: String?
    let description: String?
    let feedImage: Image?
    let isLoading: Bool
    let isRetryButtonHidden: Bool
}

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {

    typealias ImageTransformer = (Data) -> Image?

    private let feedImageView: View
    private let imageTransformer: ImageTransformer

    init(feedImageView: View, imageTransformer: @escaping ImageTransformer) {
        self.feedImageView = feedImageView
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImage(for model: FeedImage) {
        feedImageView.display(
            makeFeedImageViewModel(
                model: model,
                feedImage: nil,
                isLoading: true,
                isRetryButtonHidden: true
            )
        )
    }

    func didFinishLoadingImageData(_ imageData: Data, with model: FeedImage) {
        guard let image = imageTransformer(imageData) else {
            return
        }
        feedImageView.display(
            makeFeedImageViewModel(
                model: model,
                feedImage: image,
                isLoading: false,
                isRetryButtonHidden: true
            )
        )
    }

    private func makeFeedImageViewModel(model: FeedImage, feedImage: Image?, isLoading: Bool, isRetryButtonHidden: Bool) -> FeedImageViewModel<Image> {
        FeedImageViewModel(
            isLocationContainerHidden: model.location == nil,
            location: model.location,
            description: model.description,
            feedImage: feedImage,
            isLoading: isLoading,
            isRetryButtonHidden: isRetryButtonHidden
        )
    }

}

final class FeedImagePresenterTests: XCTestCase {

    private typealias ImageTransformer = FeedImagePresenter<FeedImagePresenterTests.ViewSpy, FakeImage>.ImageTransformer

    func test_feedImagePresenter_doesNotSendMessagesWhenInstantiated() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty)
    }

    func test_feedImagePresenter_hidesLocationContainerWhenEmptyAndPassesItWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingImage(for: makeFakeFeedImage(location: nil))
        XCTAssertTrue(view.messages.contains(.display(isLocationContainerHidden: true)))
        XCTAssertTrue(view.messages.contains(.display(location: nil)))
    }

    func test_feedImagePresenter_showsLocationContainerNotEmptyAndPassesITWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingImage(for: makeFakeFeedImage(location: "not nil"))
        XCTAssertTrue(view.messages.contains(.display(isLocationContainerHidden: false)))
        XCTAssertTrue(view.messages.contains(.display(location: "not nil")))
    }

    func test_feedImagePresenter_passesDescriptionWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingImage(for: makeFakeFeedImage(description: "any description"))
        XCTAssertTrue(view.messages.contains(.display(description: "any description")))
    }

    func test_feedImagePresenter_displayNilFeedImageWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingImage(for: makeFakeFeedImage())
        XCTAssertTrue(view.messages.contains(.display(feedImage: nil)))
    }

    func test_feedImagePresenter_sendsIsLoadingMessageAndHidesRetryButtonWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingImage(for: makeFakeFeedImage())
        XCTAssertTrue(view.messages.contains(.display(isLoading: true, isRetryButtonHidden: true)))
    }

    func test_feedImagePresenter_stopsLoadingAndHidesRetryButtonWhenItFinishesLoading() {
        let (presenter, view) = makeSUT()

        presenter.didFinishLoadingImageData(Data(), with: makeFakeFeedImage())
        XCTAssertTrue(view.messages.contains(.display(isLoading: false, isRetryButtonHidden: true)))
    }

    func test_feedImagePresenter_transformsImageDataToImageWhenItFinishesLoading() {
        let (presenter, view) = makeSUT(imageTransformer: { FakeImage(data: $0) })

        let anyData = Data()
        presenter.didFinishLoadingImageData(anyData, with: makeFakeFeedImage())
        XCTAssertTrue(view.messages.contains(.display(feedImage: FakeImage(data: anyData))))
    }

    // MARK: - Helpers

    private func makeSUT(
        imageTransformer: @escaping ImageTransformer = { FakeImage(data: $0) },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImagePresenter<FeedImagePresenterTests.ViewSpy, FakeImage>, ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedImagePresenter<FeedImagePresenterTests.ViewSpy, FakeImage>(feedImageView: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(presenter, file: file, line: line)
        return (presenter, view)
    }

    private func makeFakeFeedImage(location: String? = nil, description: String? = nil) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: URL(string: "https://some-url.com")!)
    }

    private class ViewSpy: FeedImageView {
        typealias Image = FakeImage

        enum Message: Hashable {
            case display(isLocationContainerHidden: Bool)
            case display(location: String?)
            case display(description: String?)
            case display(feedImage: Image?)
            case display(isLoading: Bool, isRetryButtonHidden: Bool)
            case display(transformedImage: Image)
        }
        private(set) var messages: Set<Message> = []

        func display(_ viewModel: FeedImageViewModel<FakeImage>) {
            messages.insert(.display(isLocationContainerHidden: viewModel.isLocationContainerHidden))
            messages.insert(.display(location: viewModel.location))
            messages.insert(.display(description: viewModel.description))
            messages.insert(.display(feedImage: viewModel.feedImage))
            messages.insert(.display(isLoading: viewModel.isLoading, isRetryButtonHidden: viewModel.isRetryButtonHidden))
        }
    }

    private struct FakeImage: Hashable {
        let data: Data
    }

}
