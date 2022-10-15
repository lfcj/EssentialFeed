import Foundation

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

    public static let feedLoadError = NSLocalizedString(
        "GENERIC_CONNECTION_ERROR",
        tableName: "Shared",
        bundle: Bundle(for: FeedPresenter.self),
        comment: "Error message displayed when we cannot load the feed from server"
    )

    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    private let feedView: FeedView

    public init(feedView: FeedView, loadingView: ResourceLoadingView, errorView: ResourceErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(Self.map(feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: Self.feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }

    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }

}
