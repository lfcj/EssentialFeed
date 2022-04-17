import EssentialFeed
import Foundation
import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImageDataLoad()
    func didRequestCancellingImageDataLoad()
}

final class FeedImageCellController: FeedImageView {

    private let delegate: FeedImageCellControllerDelegate

    private let view: FeedImageCell

    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        self.view = FeedImageCell()
        prepareCellForReuse()
    }

    func preload() {
        delegate.didRequestImageDataLoad()
    }

    func cancelLoad() {
        delegate.didRequestCancellingImageDataLoad()
    }

    func cell() -> UITableViewCell {
        view.onRetry = delegate.didRequestImageDataLoad
        delegate.didRequestImageDataLoad()
        return view
    }

    // MARK: - FeedImageView

    func display(_ viewModel: FeedImageViewModel<UIImage>) {
        view.display(viewModel)
    }

    private func prepareCellForReuse() {
        view.display(
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

    deinit {
        cancelLoad()
    }

}
