import EssentialFeed
import EssentialFeediOS
import Foundation

extension FeedUIIntegrationTests {
    class LoaderSpy: FeedLoader, FeedImageDataLoader {

        // MARK: - FeedLoader

        var loadFeedCallCount: Int { feedRequests.count }
        private(set) var cancelledImageURLs = [URL]()
        private var feedRequests = [(FeedLoader.Result) -> Void]()

        func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
            feedRequests.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int = 0) {
            feedRequests[index](.failure(anyNSError()))
        }

        private func anyNSError() -> NSError {
            NSError(domain: "any", code: 0, userInfo: nil)
        }

        // MARK: - FeedImageDataLoader

        private struct TaskSpy: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() { cancelCallback() }
        }

        typealias ImageRequestCompletion = (FeedImageDataLoader.Result) -> Void
        var loadedImageURLs: [URL] { imageRequests.map { $0.url } }
        private(set) var cancelledImagesURLs = [URL]()

        private var imageRequests = [(url: URL, completion: ImageRequestCompletion)]()

        func loadImageData(from url: URL, completion: @escaping ImageRequestCompletion) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }

        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completion(.success(imageData))
        }

        func completeImageLoadingWithError(at index: Int = 0) {
            imageRequests[index].completion(.failure(anyNSError()))
        }

    }
}
