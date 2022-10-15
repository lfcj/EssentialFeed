import EssentialFeed
import XCTest

public struct ResourceViewModel {
}

public struct ResourceLoadingViewModel {
    public let isLoading: Bool
}

public protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

public struct ResourceErrorViewModel {
    public let message: String?
}

public protocol ResourceErrorView: AnyObject {
    func display(_ viewModel: ResourceErrorViewModel)
}
public protocol ResourceView {
    func display(_ viewModel: ResourceViewModel)
}

final class LoadResourcePresenterTests: XCTestCase {

    func test_resourcePresenter_doesNotSendAnythingOnInitialisation() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages")
    }
    func test_feedPresenter_displaysNoErrorAndStartsLoadingWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }

    func test_feedPresenter_displaysFeedAndStopsLoadingWhenLoadingFeedFinishes() {
        let (presenter, view) = makeSUT()

        presenter.didFinishLoadingFeed(with: [])
        XCTAssertEqual(view.messages, [.display(feed: []), .display(isLoading: false)])
    }

    func test_feedPresenter_displaysErrorMessageAndStopsLoadingWhenFeedFinishes() {
        let (presenter, view) = makeSUT()

        let error = NSError(domain: "any", code: 0)
        presenter.didFinishLoadingFeed(with: error)
        XCTAssertEqual(view.messages, [.display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")), .display(isLoading: false)])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LoadResourcePresenter, ViewSpy) {
        let view = ViewSpy()
        let presenter = LoadResourcePresenter(feedView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(presenter, file: file, line: line)
        return (presenter, view)
    }

    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing value for key: \(key) in table: \(table)", file: file, line: line)
        }

        return value
    }

    private class ViewSpy: FeedLoadingView, FeedErrorView, FeedView {
        
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(feed: [FeedImage])
        }

        private(set) var messages: Set<Message> = []

        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }

}
