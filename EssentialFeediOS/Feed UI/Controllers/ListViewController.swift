import EssentialFeed
import UIKit

public protocol CellController {
    func view(in tableView: UITableView) -> UITableViewCell
    func preload()
    func cancelLoad()
}

public final class ListViewController: UITableViewController, ResourceLoadingView, ResourceErrorView {

    public typealias RefreshHandler = () -> Void

    public var onRefresh: RefreshHandler?

    @IBOutlet private(set) public var errorView: ErrorView?

    private var loadingControllersByIndexPath: [IndexPath: CellController] = [:]

    private var tableModel = [CellController]() {
        didSet {
            tableView.reloadData()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
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
        onRefresh?()
    }

    // MARK: - FeedLoadingView

    public func display(_ tableModel: [CellController]) {
        loadingControllersByIndexPath = [:]
        self.tableModel = tableModel
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }

    // MARK: - FeedErrorView

    public func display(_ viewModel: ResourceErrorViewModel) {
        if let errorMessage = viewModel.message {
            errorView?.show(message: errorMessage)
        } else {
            errorView?.hideMessage()
        }
    }

    // MARK: - Private Logic

    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllersByIndexPath[indexPath] = controller
        return controller
    }

}

// MARK: - UITableViewDataSourcePrefetching

extension ListViewController: UITableViewDataSourcePrefetching {

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancellCellControllerLoad)
    }

    private func cancellCellControllerLoad(at rowIndexPath: IndexPath) {
        loadingControllersByIndexPath[rowIndexPath]?.cancelLoad()
        loadingControllersByIndexPath[rowIndexPath] = nil
    }

}
