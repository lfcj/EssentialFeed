import Foundation

public struct FeedImageViewModel<Image> {
    public let isLocationContainerHidden: Bool
    public let location: String?
    public let description: String?
    public let feedImage: Image?
    public let isLoading: Bool
    public let isRetryButtonHidden: Bool

    public init(
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
