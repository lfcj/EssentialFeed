import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader, FeedImageDataCache {

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }

    public enum SaveError: Swift.Error {
        case failed
    }

    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let imageData = try store.retrieve(dataForURL: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }
        throw LoadError.notFound
    }

    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }

}
