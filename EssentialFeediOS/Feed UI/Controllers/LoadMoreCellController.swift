import EssentialFeed
import UIKit

public class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    
    private let cell = LoadMoreCell()
    
    private let willDisplayHandler: () -> Void

    // MARK: - Init/Deinit
    
    public init(loadMoreHandler: @escaping () -> Void) {
        self.willDisplayHandler = loadMoreHandler
    }

    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }

    // MARK: - UITableViewDelegate

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplayHandler()
    }
    
}

extension LoadMoreCellController: ResourceLoadingView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}
