import EssentialFeed
import UIKit

public class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    private let cell = LoadMoreCell()
    
    private let willDisplayHandler: () -> Void
    private var offsetObserver: NSKeyValueObservation?

    // MARK: - Init/Deinit
    
    public init(loadMoreHandler: @escaping () -> Void) {
        self.willDisplayHandler = loadMoreHandler
    }

    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - UITableViewDelegate

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        reloadIfNeeded()

        offsetObserver = tableView.observe(\.contentOffset, options: .new) { [weak self] (tableView, _) in
            guard tableView.isDragging else {
                return
            }

            self?.reloadIfNeeded()
        }
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        offsetObserver = nil
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reloadIfNeeded()
    }

    // MARK: - Helpers

    private func reloadIfNeeded() {
        guard !self.cell.isLoading else {
            return
        }

        willDisplayHandler()
    }
    
}

extension LoadMoreCellController: ResourceLoadingView, ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}
