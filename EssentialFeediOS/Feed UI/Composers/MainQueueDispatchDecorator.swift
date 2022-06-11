import EssentialFeed
import Foundation

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    private func distach(_ block: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: block)
        }
        block()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.distach { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {}

    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.distach { completion(result) }
        }
    }
}

