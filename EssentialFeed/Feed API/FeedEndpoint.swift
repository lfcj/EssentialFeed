import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        baseURL.appendingPathComponent("/v1/feed")
    }
}
