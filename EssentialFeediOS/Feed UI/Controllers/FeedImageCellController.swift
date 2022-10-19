import EssentialFeed
import Foundation
import UIKit

public protocol FeedImageCellControllerDelegate {
    func didRequestImageData()
    func didRequestCancellingImageDataLoad()
}

public final class FeedImageCellController: CellController, ResourceView, ResourceLoadingView, ResourceErrorView {

    public typealias ResourceViewModel = UIImage

    private let viewModel: FeedImageViewModel<UIImage>
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?

    public init(viewModel: FeedImageViewModel<UIImage>, delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        prepareCellForReuse()
    }

    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = delegate.didRequestImageData
        delegate.didRequestImageData()
        return cell!
    }

    public func preload() {
        delegate.didRequestImageData()
    }

    public func cancelLoad() {
        releaseCellForReuse()
        delegate.didRequestCancellingImageDataLoad()
    }

    // MARK: - ResourceView

    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }

    // MARK: - ResourceLoadingView

    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }

    // MARK: - ResourceErrorView

    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }

    private func prepareCellForReuse() {
        cell?.feedImageContainer.isShimmering = false
        cell?.locationContainer.isHidden = true
        cell?.feedImageView.image = nil
        cell?.descriptionLabel.text = nil
        cell?.feedImageRetryButton.isHidden = true
    }

    private func releaseCellForReuse() {
        cell = nil
    }

    deinit {
        cancelLoad()
    }

}
