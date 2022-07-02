import XCTest

struct FeedLoadingViewModel {
    let isLoading: Bool
}
protocol FeedLoadingView: AnyObject {
    func display(_ viewModel: FeedLoadingViewModel)
}
struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
protocol FeedErrorView: AnyObject {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {

    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView

    init(loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.loadingView = loadingView
        self.errorView = errorView
    }

    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

}

final class FeedPresenterTests: XCTestCase {

    func test_feedPresenter_doesNotSendAnythingOnInitialisation() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages")
    }

    func test_feedPresenter_displaysNoErrorAndStartsLoadingWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let presenter = FeedPresenter(loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(presenter, file: file, line: line)
        return (presenter, view)
    }

    private class ViewSpy: FeedLoadingView, FeedErrorView {
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
        }

        private(set) var messages: Set<Message> = []

        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }

}
