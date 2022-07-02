import EssentialFeed
import Foundation

protocol FeedErrorView: AnyObject {
    func display(_ viewModel: FeedErrorViewModel)
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
struct FeedLoadingViewModel {
    let isLoading: Bool
}
protocol FeedLoadingView: AnyObject {
    func display(_ viewModel: FeedLoadingViewModel)
}
struct FeedViewModel {
    let feed: [FeedImage]
}
protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {

    static let title = NSLocalizedString(
        "FEED_VIEW_TITLE",
        tableName: "Feed",
        bundle: Bundle(for: FeedPresenter.self),
        comment: "Title for the feed view"
    )

    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView

    init(feedView: FeedView, loadingView: FeedLoadingView, feedErrorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = feedErrorView
    }

    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

}
