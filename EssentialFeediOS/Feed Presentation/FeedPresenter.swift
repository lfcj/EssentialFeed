import EssentialFeed
import Foundation

protocol FeedErrorView: AnyObject {
    func display(_ viewModel: FeedErrorViewModel)
}
protocol FeedLoadingView: AnyObject {
    func display(_ viewModel: FeedLoadingViewModel)
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

    private var feedLoadError: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we cannot load the feed from server"
        )
    }

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
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

}
