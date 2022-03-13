import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageContainer: UIView!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        locationImageView?.alpha = 0
        feedImageContainer.startShimmering()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        locationImageView?.alpha = 0
        feedImageContainer.startShimmering()
    }

    func fadeIn(_ image: UIImage?) {
        locationImageView.image = image

        UIView.animate(
            withDuration: 0.3,
            delay: 0.3,
            options: [],
            animations: {
                self.locationImageView?.alpha = 1
            },
            completion: { finished in
                guard finished else { return }
                self.feedImageContainer.stopShimmering()
            }
        )
    }

    func configure(with viewModel: FeedImageViewModel) {
        self.locationLabel.text = viewModel.location
        self.descriptionLabel.text = viewModel.description

        self.locationContainer.isHidden = viewModel.location == nil
        self.descriptionLabel.isHighlighted = viewModel.description == nil

        fadeIn(UIImage(named: viewModel.imageName))
    }
}

private extension UIView {
    private var shimmerAnimationKey: String { "shimmer" }

    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height

        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient

        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
     }

     func stopShimmering() {
         layer.mask = nil
     }
 }
