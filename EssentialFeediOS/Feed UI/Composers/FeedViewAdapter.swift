import Foundation
import UIKit

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader

    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let imagePresentationAdapter = FeedImagerLoaderPresentationAdapter(feedImageLoader: loader, model: model)
            let feedCellController = FeedImageCellController(delegate: imagePresentationAdapter)
            imagePresentationAdapter.presenter = FeedImagePresenter(
                feedImageView: WeakRefVirtualProxy(feedCellController),
                imageTransformer: UIImage.init
            )
            return feedCellController
        }
    }
}
