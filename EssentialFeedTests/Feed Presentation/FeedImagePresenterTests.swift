import EssentialFeed
import XCTest

struct FeedImageViewModel {
    let isLocationContainerHidden: Bool
}

protocol FeedImageView {
    func display(_ viewModel: FeedImageViewModel)
}

final class FeedImagePresenter {

    private let feedImageView: FeedImageView
    init(feedImageView: FeedImageView) {
        self.feedImageView = feedImageView
    }

    func didStartLoadingImage(for model: FeedImage) {
        feedImageView.display(
            makeFeedImageViewModel(
                model: model
            )
        )
    }

    private func makeFeedImageViewModel(model: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            isLocationContainerHidden: model.location == nil
        )
    }

}

final class FeedImagePresenterTests: XCTestCase {

    func test_feedImagePresenter_doesNotSendMessagesWhenInstantiated() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty)
    }

    func test_feedImagePresenter_hidesLocationContainerWhenLocationIsEmpty() {
        let (presenter, view) = makeSUT()

        let expectedFeedImage = makeFakeFeedImage(location: nil)
        presenter.didStartLoadingImage(for: expectedFeedImage)
        XCTAssertTrue(view.messages.contains(.display(isLocationContainerHidden: true)))
    }

    func test_feedImagePresenter_showsLocationContainerWhenLocationIsNotEmpty() {
        let (presenter, view) = makeSUT()

        let expectedFeedImage = makeFakeFeedImage(location: "not nil")
        presenter.didStartLoadingImage(for: expectedFeedImage)
        XCTAssertTrue(view.messages.contains(.display(isLocationContainerHidden: false)))
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImagePresenter, ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedImagePresenter(feedImageView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(presenter, file: file, line: line)
        return (presenter, view)
    }

    private func makeFakeFeedImage(location: String? = nil) -> FeedImage {
        FeedImage(id: UUID(), description: "any", location: location, url: URL(string: "https://some-url.com")!)
    }

    private class ViewSpy: FeedImageView {
        enum Message: Hashable {
            case display(isLocationContainerHidden: Bool)
        }
        private(set) var messages: Set<Message> = []

        func display(_ viewModel: FeedImageViewModel) {
            messages.insert(.display(isLocationContainerHidden: viewModel.isLocationContainerHidden))
        }
    }
}
