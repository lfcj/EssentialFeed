import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    public static func feedComposed(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(
            forwardingTo: feedViewController,
            loader: imageLoader
        )
        return feedViewController
    }

    private static func adaptFeedToCellControllers(
        forwardingTo controller: FeedViewController,
        loader: FeedImageDataLoader
    ) -> FeedViewModel.Observer<[FeedImage]> {
        { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellController(
                    viewModel: FeedImageViewModel(model: model, imageLoader: loader, imageTransformer: UIImage.init)
                )
            }
        }
    }
}
