import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        locationImageView?.alpha = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        locationImageView?.alpha = 0
    }

    func fadeIn(_ image: UIImage?) {
        locationImageView.image = image

        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: []
        ) {
            self.locationImageView?.alpha = 1
        }
    }

    func configure(with viewModel: FeedImageViewModel) {
        self.locationLabel.text = viewModel.location
        self.descriptionLabel.text = viewModel.description

        self.locationContainer.isHidden = viewModel.location == nil
        self.descriptionLabel.isHighlighted = viewModel.description == nil

        fadeIn(UIImage(named: viewModel.imageName))
    }
}
