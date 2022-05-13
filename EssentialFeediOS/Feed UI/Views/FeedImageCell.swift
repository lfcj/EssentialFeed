import UIKit

public final class FeedImageCell: UITableViewCell, FeedImageView {
    typealias Image = UIImage
    
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
    
    // MARK: - FeedImageView

    func display(_ viewModel: FeedImageViewModel<Image>) {
        feedImageContainer.isShimmering = viewModel.isLoading
        locationContainer.isHidden = viewModel.isLocationContainerHidden
        locationLabel.text = viewModel.location
        descriptionLabel.text = viewModel.description
        feedImageView.image = viewModel.feedImage
        feedImageRetryButton.isHidden = viewModel.isRetryButtonHidden
    }
    
}
