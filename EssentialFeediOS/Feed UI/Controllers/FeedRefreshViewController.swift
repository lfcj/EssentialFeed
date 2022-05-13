import UIKit

protocol FeedRefreshViewControllerDelegate: AnyObject {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {

    @IBOutlet var view: UIRefreshControl?
    var delegate: FeedRefreshViewControllerDelegate?

    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    // MARK: - FeedLoadingView

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }

}
