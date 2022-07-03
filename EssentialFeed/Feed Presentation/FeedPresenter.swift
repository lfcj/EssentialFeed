import Foundation

public protocol FeedLoadingView: AnyObject {
    func display(_ viewModel: FeedLoadingViewModel)
}
public protocol FeedErrorView: AnyObject {
    func display(_ viewModel: FeedErrorViewModel)
}
public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {

    public static let title = NSLocalizedString(
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

    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let feedView: FeedView

    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

}
