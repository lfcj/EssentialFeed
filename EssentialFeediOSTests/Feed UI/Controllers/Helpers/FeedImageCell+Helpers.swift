import EssentialFeediOS
import Foundation
import UIKit

extension FeedImageCell {

    var isShowingLocation: Bool { !locationContainer.isHidden }
    var locationText: String? { locationLabel.text }
    var descriptionText: String? { descriptionLabel.text }
    var isShowingImageLoadingIndicator: Bool { feedImageContainer.isShimmering }
    var renderedImage: Data? { feedImageView.image?.pngData() }
    var isShowingRetryAcition: Bool { !feedImageRetryButton.isHidden }

    func simulateRetryAction() { feedImageRetryButton.simulateTap() }

}

private extension UIButton {

    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }

}
