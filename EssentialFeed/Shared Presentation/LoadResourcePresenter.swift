import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel

    private let mapper: Mapper
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    private let resourceView: View

    private var feedLoadError: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we cannot load the feed from server"
        )
    }

    public init(
        mapper: @escaping Mapper,
        resourceView: View,
        loadingView: FeedLoadingView,
        errorView: FeedErrorView
    ) {
        self.mapper = mapper
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoading() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    public func didFinishLoading(with resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

}
