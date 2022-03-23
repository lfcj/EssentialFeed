import EssentialFeed
import Foundation
import UIKit

final class FeedImageCellController {

    private var imageLoadingTask: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader

    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func preload() {
        imageLoadingTask = imageLoader.loadImageData(from: self.model.url) { _ in }
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = model.location == nil
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.imageLoadingTask = self.imageLoader.loadImageData(from: self.model.url) { [weak cell] result in
                if let data = try? result.get(), let image = UIImage(data: data) {
                    cell?.feedImageView.image = image
                } else {
                    cell?.feedImageRetryButton.isHidden = false
                }
                cell?.feedImageContainer.stopShimmering()
            }
        }

        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    deinit {
        imageLoadingTask?.cancel()
    }

}
