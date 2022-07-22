import EssentialFeed
import UIKit

public final class FeedImageCell: UITableViewCell, FeedImageView {
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
    
    // MARK: - FeedImageView

    public func display(_ viewModel: FeedImageViewModel<Image>) {
        feedImageContainer.isShimmering = viewModel.isLoading
        locationContainer.isHidden = viewModel.isLocationContainerHidden
        locationLabel.text = viewModel.location
        descriptionLabel.text = viewModel.description
        feedImageView.setImageAnimated(viewModel.feedImage)
        feedImageRetryButton.isHidden = viewModel.isRetryButtonHidden
    }
    
}

