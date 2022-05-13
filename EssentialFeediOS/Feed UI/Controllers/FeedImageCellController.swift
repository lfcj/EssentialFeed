import EssentialFeed
import Foundation
import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImageDataLoad()
    func didRequestCancellingImageDataLoad()
}

final class FeedImageCellController: FeedImageView {

    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        prepareCellForReuse()
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.onRetry = delegate.didRequestImageDataLoad
        delegate.didRequestImageDataLoad()
        return cell!
    }

    func preload() {
        delegate.didRequestImageDataLoad()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didRequestCancellingImageDataLoad()
    }

    // MARK: - FeedImageView

    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.display(viewModel)
    }

    private func prepareCellForReuse() {
        cell?.display(
            FeedImageViewModel(
                isLocationContainerHidden: true,
                location: nil,
                description: nil,
                feedImage: nil,
                isLoading: false,
                isRetryButtonHidden: true
            )
        )
    }

    private func releaseCellForReuse() {
        cell = nil
    }

    deinit {
        cancelLoad()
    }

}
