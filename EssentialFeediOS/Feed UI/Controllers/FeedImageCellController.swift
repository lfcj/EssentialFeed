import EssentialFeed
import Foundation
import UIKit

public protocol FeedImageCellControllerDelegate {
    func didRequestImageData()
    func didRequestCancellingImageDataLoad()
}


    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?

    public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        prepareCellForReuse()
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.onRetry = delegate.didRequestImageData
        delegate.didRequestImageData()
        return cell!
    }

    func preload() {
        delegate.didRequestImageData()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didRequestCancellingImageDataLoad()
    }


    }

    private func prepareCellForReuse() {
    }

    private func releaseCellForReuse() {
        cell = nil
    }

    deinit {
        cancelLoad()
    }

}
