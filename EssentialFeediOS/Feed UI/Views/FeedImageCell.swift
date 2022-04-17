import UIKit

public final class FeedImageCell: UITableViewCell, FeedImageView {
    typealias Image = UIImage
    
    public let feedImageContainer = UIView()
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageView = UIImageView()

    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?

    @objc private func retryButtonTapped() {
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
