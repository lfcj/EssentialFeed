import EssentialFeed
import Foundation

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

    init(feedView: FeedView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }

    func didStartLoadingFeed() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.didStartLoadingFeed() }
            return
        }
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingFeed(with feed: [FeedImage]) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: feed) }
            return
        }
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingFeed(with error: Error) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: error) }
            return
        }
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }

}
