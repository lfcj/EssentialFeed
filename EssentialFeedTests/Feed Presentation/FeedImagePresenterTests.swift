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

    private let feedImageView: View
    init(feedImageView: View) {
        self.feedImageView = feedImageView
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

    func test_feedImagePresenter_displaysIsLoadingMessageAndHidesRetryButtonWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingImage(for: makeFakeFeedImage())
        XCTAssertTrue(view.messages.contains(.display(isLoading: true, isRetryButtonHidden: true)))
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImagePresenter<FeedImagePresenterTests.ViewSpy, FakeImage>, ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedImagePresenter<FeedImagePresenterTests.ViewSpy, FakeImage>(feedImageView: view)
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
    private struct FakeImage: Hashable {}
}
