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
        case connectivity
        case invalidData
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion: completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else {
                return
            }
            task.complete(
                with: result
                    .mapError { _ in Error.connectivity }
                    .flatMap { (data, response) in
                        let isValidResponse = !data.isEmpty && response.statusCode == 200
                        return isValidResponse ? .success(data) : .failure(Error.invalidData)
                    }
            )
        }
        return task
    }

}
