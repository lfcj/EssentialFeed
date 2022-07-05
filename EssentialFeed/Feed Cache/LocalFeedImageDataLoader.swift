import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {

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
        store.retrieve(dataForURL: url) { result in
            task .complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    if let data = data, !data.isEmpty {
                        return .success(data)
                    } else {
                        return .failure(LoadError.notFound)
                    }
                }
            )
        }
        return task
    }

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else {
                return
            }
            completion(result.mapError { _ in SaveError.failed })
        }
    }

}
