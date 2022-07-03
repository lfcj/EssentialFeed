import EssentialFeed
import XCTest

struct FeedImageViewModel {
    let isLocationContainerHidden: Bool
    let location: String?
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
            isLocationContainerHidden: model.location == nil,
            location: model.location
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
            case display(location: String?)
        }
        private(set) var messages: Set<Message> = []

        func display(_ viewModel: FeedImageViewModel) {
            messages.insert(.display(isLocationContainerHidden: viewModel.isLocationContainerHidden))
            messages.insert(.display(location: viewModel.location))
        }
    }
}
