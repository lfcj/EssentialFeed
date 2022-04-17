import Foundation

struct FeedImageViewModel<Image> {
    let isLocationContainerHidden: Bool
    let location: String?
    let description: String?
    let feedImage: Image?
    let isLoading: Bool
    let isRetryButtonHidden: Bool

    init(
        isLocationContainerHidden: Bool = true,
        location: String? = nil,
        description: String? = nil,
        feedImage: Image? = nil,
        isLoading: Bool = false,
        isRetryButtonHidden: Bool = true
    ) {
        self.isLocationContainerHidden = isLocationContainerHidden
        self.location = location
        self.description = description
        self.feedImage = feedImage
        self.isLoading = isLoading
        self.isRetryButtonHidden = isRetryButtonHidden
    }
}
