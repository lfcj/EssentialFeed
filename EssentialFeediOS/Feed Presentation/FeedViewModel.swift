import EssentialFeed

final class FeedViewModel {

    // MARK: - Nested Types

    typealias Observer<T> = (T) -> Void

    // MARK: - Properties

    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?

    private let feedLoader: FeedLoader

    // MARK: - Init/Deinit

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    // MARK: - Feed Loading

    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }

}
