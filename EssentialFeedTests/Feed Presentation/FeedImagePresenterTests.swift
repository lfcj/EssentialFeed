import EssentialFeed
import XCTest

final class FeedImagePresenterTests: XCTestCase {

    private typealias ImageTransformer = FeedImagePresenter<FeedImagePresenterTests.ViewSpy, FakeImage>.ImageTransformer

    func test_feedImagePresenter_doesNotSendMessagesWhenInstantiated() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty)
    }

    func test_feedImagePresenter_usesEnteredModelHideLocationAndPassesBothLocationAndDescriptionWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingImage(for: makeFakeFeedImage(location: nil, description: nil))
        XCTAssertTrue(view.messages.contains(.display(isLocationContainerHidden: true, location: nil, description: nil)))
    }

    func test_feedImagePresenter_usesEnteredModelShowLocationAndPassesBothLocationAndDescriptionWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingImage(for: makeFakeFeedImage(location: "not nil", description: "any"))
        XCTAssertTrue(view.messages.contains(.display(isLocationContainerHidden: false, location: "not nil", description: "any")))
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

    func test_feedImagePresenter_sendsNilFeedImageAndShowsRetryButtonAfterItFinishesLoadingAndDataFailedtoBeTransformedToImage() {
        let (presenter, view) = makeSUT(imageTransformer: { _ in nil })

        presenter.didFinishLoadingImageData(Data(), with: makeFakeFeedImage())
        XCTAssertTrue(view.messages.contains(.display(isLoading: false, isRetryButtonHidden: false)))
        XCTAssertTrue(view.messages.contains(.display(feedImage: nil)))
    }

    func test_feedImagePresenter_completesEquallyWhenFailingToTransformDataToImageAsWhenItFinishesLoadingWithError() {
        let (presenterWithDataToNilTransformer, viewWithDataToNilTransformer) = makeSUT(imageTransformer: { _ in nil })
        let (presenterThatWillCompleteWithError, viewThatWillCompleteWithError) = makeSUT()

        struct FakeError: Error {}

        presenterWithDataToNilTransformer.didFinishLoadingImageData(Data(), with: makeFakeFeedImage())
        presenterThatWillCompleteWithError.didFinishLoadingImageData(with: FakeError(), model: makeFakeFeedImage())

        XCTAssertEqual(viewWithDataToNilTransformer.messages, viewThatWillCompleteWithError.messages)
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
            case display(isLocationContainerHidden: Bool, location: String?, description: String?)
            case display(feedImage: Image?)
            case display(isLoading: Bool, isRetryButtonHidden: Bool)
            case display(transformedImage: Image)
            case display(error: NSError)
        }
        private(set) var messages: Set<Message> = []

        func display(_ viewModel: FeedImageViewModel<FakeImage>) {
            messages.insert(
                .display(
                    isLocationContainerHidden: viewModel.isLocationContainerHidden,
                    location: viewModel.location,
                    description: viewModel.description
                )
            )
            messages.insert(.display(feedImage: viewModel.feedImage))
            messages.insert(.display(isLoading: viewModel.isLoading, isRetryButtonHidden: viewModel.isRetryButtonHidden))
        }
    }

    private struct FakeImage: Hashable {
        let data: Data
    }

}
