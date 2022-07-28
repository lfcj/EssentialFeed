import EssentialFeed
import UIKit

public protocol FeedViewControllerDelegate: AnyObject {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, FeedLoadingView, FeedErrorView {

    public var delegate: FeedViewControllerDelegate?

    @IBOutlet private(set) public var errorView: ErrorView?

    private var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(in: tableView)
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancellCellControllerLoad(at: indexPath)
    }

    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }

    // MARK: - FeedLoadingView

    public func display(_ tableModel: [FeedImageCellController]) {
        self.tableModel = tableModel
    }

    public func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }

    // MARK: - FeedErrorView

    public func display(_ viewModel: FeedErrorViewModel) {
        if let errorMessage = viewModel.message {
            errorView?.show(message: errorMessage)
        } else {
            errorView?.hideMessage()
        }
    }

    // MARK: - Private Logic

    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        tableModel[indexPath.row]
    }

}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewController: UITableViewDataSourcePrefetching {

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancellCellControllerLoad)
    }

    private func cancellCellControllerLoad(at rowIndexPath: IndexPath) {
        cellController(forRowAt: rowIndexPath).cancelLoad()
    }

}
