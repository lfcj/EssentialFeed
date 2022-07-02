import XCTest

struct FeedLoadingViewModel {
    let isLoading: Bool
}
protocol FeedLoadingView: AnyObject {
    func display(_ viewModel: FeedLoadingViewModel)
}

final class FeedPresenter {

    private let loadingView: FeedLoadingView

    init(loadingView: FeedLoadingView) {
        self.loadingView = loadingView
    }

    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

}

final class FeedPresenterTests: XCTestCase {

    func test_feedPresenter_doesNotSendAnythingOnInitialisation() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages")
    }

    func test_feedPresenter_sendsMessageWhenItStartsLoadingFeed() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(isLoading: true)])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedPresenter(loadingView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(presenter, file: file, line: line)
        return (presenter, view)
    }

    private class ViewSpy: FeedLoadingView {
        enum Message: Equatable {
            case display(isLoading: Bool)
        }

        private(set) var messages: [Message] = []

        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
    }

}
