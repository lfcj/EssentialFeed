import EssentialFeed
import Foundation
import UIKit

public protocol FeedImageCellControllerDelegate {
    func didRequestImageData()
    func didRequestCancellingImageDataLoad()
}

public final class FeedImageCellController:
    NSObject,
    UITableViewDataSource,
    UITableViewDelegate,
    UITableViewDataSourcePrefetching,
    ResourceView,
    ResourceLoadingView,
    ResourceErrorView
 {

    public typealias ResourceViewModel = UIImage

    private let viewModel: FeedImageViewModel<UIImage>
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?

    public init(viewModel: FeedImageViewModel<UIImage>, delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init()
        prepareCellForReuse()
    }

    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = { [weak self] in self?.delegate.didRequestImageData() }
        delegate.didRequestImageData()
        return cell!
    }

    // MARK: - UITableViewDataSourcePrefetching

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestImageData()
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestCancellingImageDataLoad()
    }

    // MARK: - UITableViewDelegate

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoad()
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

    // MARK: - Helpers

    private func cancelLoad() {
        releaseCellForReuse()
        delegate.didRequestCancellingImageDataLoad()
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
