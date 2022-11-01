import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader, FeedImageDataCache {

    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }

    public enum SaveError: Swift.Error {
        case failed
    }

    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            completion = nil
        }
    }

    private let store: FeedImageDataStore

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion: completion)

        task.complete(
            with: Swift.Result { try store.retrieve(dataForURL: url) }
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                }
        )
        return task
    }

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        completion(
            SaveResult { try store.insert(data, for: url) }
                .mapError { _ in SaveError.failed }
        )
    }

}
