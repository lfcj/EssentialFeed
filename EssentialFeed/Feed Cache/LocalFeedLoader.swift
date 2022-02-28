import Foundation

public final class LocalFeedLoader {

    private let store: FeedStore
    private let currentDate: () -> Date

    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

}

extension LocalFeedLoader {

    public typealias SaveResult = Result<Void, Error>
    public typealias SaveCompletion = (SaveResult) -> Void

    public func save(_ feed: [FeedImage], completion: @escaping SaveCompletion) {
        store.deleteCachedFeed { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.cache(feed, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ feed: [FeedImage], with completion: @escaping SaveCompletion) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }

            completion(error)
        }
    }

}

extension LocalFeedLoader: FeedLoader {

    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some(cachedFeed)) where FeedCachePolicy.validate(cachedFeed.timestamp, against: self.currentDate()):
                completion(.success(cachedFeed.feed.toModels()))

            case .success:
                completion(.success([]))
            }
        }
    }

}

extension LocalFeedLoader {

    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }

            case let .success(.some(cachedFeed)) where !FeedCachePolicy.validate(cachedFeed.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }

            case .success:
                break
            }
        }
    }

}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
