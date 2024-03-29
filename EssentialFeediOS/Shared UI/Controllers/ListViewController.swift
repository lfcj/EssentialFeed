import EssentialFeed
import UIKit

public final class ListViewController: UITableViewController, ResourceLoadingView, ResourceErrorView {
    
    public typealias RefreshHandler = () -> Void
    private typealias DataSource = UITableViewDiffableDataSource<Int, CellController>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, CellController>
    
    public var onRefresh: RefreshHandler?
    
    private(set) public var errorView = ErrorView()
    
    private lazy var dataSource: DataSource = {
        DataSource(tableView: tableView) { (tableView, indexPath, controller) -> UITableViewCell? in
            controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource
        configureHeaderView()
        refresh()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }

    // MARK: - UITableViewDelegate

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = cellController(at: indexPath)
        let delegate = controller?.delegate
        
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = cellController(at: indexPath)
        let delegate = controller?.delegate

        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = cellController(at: indexPath)
        let delegate = controller?.delegate
        
        delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    @IBAction private func refresh() {
        onRefresh?()
    }

    // MARK: - FeedLoadingView

    public func display(_ sections: [CellController]...) {
        var snapshot = Snapshot()
        sections.enumerated().forEach { section, cellControllers in
            snapshot.appendSections([section])
            snapshot.appendItems(cellControllers, toSection: section)
        }
        dataSource.apply(snapshot)
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
        errorView.message = viewModel.message
    }

    // MARK: - Private Logic

    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }

}

// MARK: - UITableViewDataSourcePrefetching

extension ListViewController: UITableViewDataSourcePrefetching {

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(at: indexPath)
            let prefetchingDataSource = controller?.dataSourcePrefetching

            prefetchingDataSource?.tableView(tableView, prefetchRowsAt: indexPaths)
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(at: indexPath)
            let prefetchingDataSource = controller?.dataSourcePrefetching
            prefetchingDataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
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
