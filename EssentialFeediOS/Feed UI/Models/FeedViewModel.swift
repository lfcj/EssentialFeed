import EssentialFeed

final class FeedViewModel {

    // MARK: - Nested Types

    typealias ChangeHandler = (Bool) -> Void
    typealias RefreshHandler = ([FeedImage]) -> Void


    // MARK: - Properties

    var onLoadingStateChange: ChangeHandler?
    var onFeedLoad: RefreshHandler?

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
