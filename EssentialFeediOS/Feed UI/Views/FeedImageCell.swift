import EssentialFeed
import UIKit

    public typealias Image = UIImage

    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!

    var onRetry: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        accessibilityIdentifier = "feed-image-cell"
        feedImageView.accessibilityIdentifier = "feed-image-view"
    }
    
}

