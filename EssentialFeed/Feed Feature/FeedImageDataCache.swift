import Foundation

public protocol FeedImageDataCache {
    typealias SaveResult = Swift.Result<Void, Swift.Error>
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
