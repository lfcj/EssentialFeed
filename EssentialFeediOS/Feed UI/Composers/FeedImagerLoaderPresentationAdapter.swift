import EssentialFeed
import Foundation
import UIKit

final class FeedImagerLoaderPresentationAdapter: FeedImageCellControllerDelegate {
    var presenter: FeedImagePresenter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>?
    private let feedImageLoader: FeedImageDataLoader
    private let model: FeedImage

    private var task: FeedImageDataLoaderTask?

    init(feedImageLoader: FeedImageDataLoader, model: FeedImage) {
        self.feedImageLoader = feedImageLoader
        self.model = model
    }

    func didRequestImageDataLoad() {
        presenter?.didStartLoadingImage(for: model)
        task = feedImageLoader.loadImageData(from: model.url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(imageData):
                self.presenter?.didFinishLoadingImageData(imageData, with: self.model)
            case let .failure(error):
                self.presenter?.didFinishLoadingImageData(with: error, model: self.model)
            }
        }
    }

    func didRequestCancellingImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
