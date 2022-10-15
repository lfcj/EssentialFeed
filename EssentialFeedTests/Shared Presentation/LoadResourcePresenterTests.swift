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

final class LoadResourcePresenterTests: XCTestCase {

    func test_presenter_doesNotSendAnythingOnInitialisation() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages")
    }

    func test_didStartLoading_displaysNoErrorAndStartsLoadingWhenItStartsLoading() {
        let (presenter, view) = makeSUT()

        presenter.didStartLoading()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }

    func test_didFinishLoadingResource_displaysResourceAndStopsLoadingWhenLoadingResourceFinishes() {
        let (presenter, view) = makeSUT(mapper: { "\($0) view model"})

        presenter.didFinishLoading(with: "resource")
        XCTAssertEqual(
            view.messages,
            [
                .display(resourceViewModel: "resource view model"),
                .display(isLoading: false)
            ]
        )
    }

    func test_didFinishLoading_displaysErrorMessageAndStopsLoading() {
        let (presenter, view) = makeSUT()
        let error = NSError(domain: "any", code: 0)

        presenter.didFinishLoading(with: error)

        XCTAssertEqual(view.messages, [.display(errorMessage: localized("GENERIC_CONNECTION_ERROR")), .display(isLoading: false)])
    }

    // MARK: - Helpers

    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { string in string },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (SUT, ViewSpy) {
        let view = ViewSpy()
        let presenter = LoadResourcePresenter(
            mapper: mapper,
            resourceView: view,
            loadingView: view,
            errorView: view
        )
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(presenter, file: file, line: line)
        return (presenter, view)
    }

    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: SUT.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing value for key: \(key) in table: \(table)", file: file, line: line)
        }

        return value
    }

    private class ViewSpy: FeedLoadingView, FeedErrorView, ResourceView {

        typealias ResourceViewModel = String

        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }

        private(set) var messages: Set<Message> = []

        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }

        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }

    }

}
