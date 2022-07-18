import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    typealias SaveCompletion = (SaveResult) -> Void
    func save(_ feed: [FeedImage], completion: @escaping SaveCompletion)
}
