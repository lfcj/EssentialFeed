import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {

    public enum Error: Swift.Error {
        case failed
        case notFound
    }

    private final class Task: FeedImageDataLoaderTask {
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
        let task = Task(completion: completion)
        store.retrieve(dataForURL: url) { result in
            task.complete(with: result
                .mapError { _ in Error.failed }
                .flatMap { data in
                    if let data = data, !data.isEmpty {
                        return .success(data)
                    } else {
                        return .failure(Error.notFound)
                    }
                }
            )
        }
        return task
    }
}
