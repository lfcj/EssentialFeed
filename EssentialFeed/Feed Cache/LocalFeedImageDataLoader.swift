import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

public final class LocalFeedImageDataLoader: FeedImageDataLoader {

    public enum Error: Swift.Error {
        case failed
    }

    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url) { result in
            completion(.failure(Error.failed))
        }
        return Task()
    }
}
