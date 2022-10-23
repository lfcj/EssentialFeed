import EssentialFeed
import UIKit

public final class ListViewController: UITableViewController, ResourceLoadingView, ResourceErrorView {

    public typealias RefreshHandler = () -> Void

    public var onRefresh: RefreshHandler?

    private(set) public var errorView = ErrorView()

    private var loadingControllersByIndexPath: [IndexPath: CellController] = [:]

    private var tableModel = [CellController]() {
        didSet {
            tableView.reloadData()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        configureHeaderView()
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
        let controller = cellController(forRowAt: indexPath)
        let dataSource = controller.dataSource
        return dataSource.tableView(tableView, cellForRowAt: indexPath)
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingController(at: indexPath)
        let delegate = controller?.delegate
        
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
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
            errorView.show(message: errorMessage)
        } else {
            errorView.hideMessageAnimated()
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
            let controller = cellController(forRowAt: indexPath)
            let prefetchingDataSource = controller.dataSourcePrefetching

            prefetchingDataSource?.tableView(tableView, prefetchRowsAt: indexPaths)
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(forRowAt: indexPath)
            let prefetchingDataSource = controller.dataSourcePrefetching
            prefetchingDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }

    private func removeLoadingController(at rowIndexPath: IndexPath) -> CellController? {
        let controller = loadingControllersByIndexPath[rowIndexPath]
        loadingControllersByIndexPath[rowIndexPath] = nil
        return controller
    }

}

// MARK: - Configuration

private extension ListViewController {

    func configureHeaderView() {
        let containerView = UIView()
        containerView.backgroundColor = nil

        containerView.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: containerView.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        tableView.tableHeaderView = containerView

        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }

}
