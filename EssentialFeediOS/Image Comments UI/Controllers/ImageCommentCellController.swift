import EssentialFeed
import UIKit

public final class ImageCommentCellController: CellController/*, ResourceView, ResourceLoadingView, ResourceErrorView*/ {

    private let model: ImageCommentViewModel

    public init(model: ImageCommentViewModel) {
        self.model = model
    }

    // MARK: - CellController

    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.dateLabel.text = model.createAtMessage
        cell.usernameLabel.text = model.username
        return cell
    }

    public func preload() {
        
    }

    public func cancelLoad() {
        
    }

}
