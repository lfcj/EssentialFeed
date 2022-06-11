import Foundation

public protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL)
}

public final class LocalFeedImageDataLoader: FeedImageDataLoader {

    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }

    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retrieve(dataForURL: url)
        return Task()
    }
}
