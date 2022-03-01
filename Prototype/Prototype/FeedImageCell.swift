import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!

    func configure(with viewModel: FeedImageViewModel) {
        self.locationLabel.text = viewModel.location
        self.locationImageView.image = UIImage(named: viewModel.imageName)
        self.descriptionLabel.text = viewModel.description

        self.locationContainer.isHidden = viewModel.location == nil
        self.descriptionLabel.isHighlighted = viewModel.description == nil
    }
}
