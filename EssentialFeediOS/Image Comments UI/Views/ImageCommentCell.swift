import EssentialFeed
import UIKit

public final class ImageCommentCell: UITableViewCell {
    @IBOutlet private(set) public var usernameLabel: UILabel!
    @IBOutlet private(set) public var messageLabel: UILabel!
    @IBOutlet private(set) public var dateLabel: UILabel!

    public override func awakeFromNib() {
        super.awakeFromNib()
        accessibilityIdentifier = "image-comment-cell"
    }
    
}

