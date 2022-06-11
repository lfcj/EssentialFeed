import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {

    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)? = nil
        var wrapped: HTTPClientTask?

        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public enum Error: Swift.Error {
        case invalidData
    }

    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion: completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else {
                return
            }
            switch result {
            case let .success((data, response)):
                if data.isEmpty || response.statusCode != 200 {
                    task.complete(with: .failure(Error.invalidData))
                } else {
                    task.complete(with: .success(data))
                }
            case .failure(let error):
                task.complete(with: .failure(error))
            }
        }
        return task
    }
}
