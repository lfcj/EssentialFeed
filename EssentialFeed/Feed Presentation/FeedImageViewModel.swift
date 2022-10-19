import Foundation

public struct FeedImageViewModel<Image> {
    public let location: String?
    public let description: String?
    public var hasLocation: Bool { location != nil }

    public init(location: String? = nil, description: String? = nil) {
        self.location = location
        self.description = description
    }
}
