import EssentialFeed

final class FeedViewModel {

    // MARK: - Nested Types

    typealias ChangeHandler = (FeedViewModel) -> Void
    typealias RefreshHandler = ([FeedImage]) -> Void


    // MARK: - Properties

    var onChange: ChangeHandler?
    var onFeedLoad: RefreshHandler?

    var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }

    private let feedLoader: FeedLoader

    // MARK: - Init/Deinit

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    // MARK: - Feed Loading

    func loadFeed() {
        isLoading = true
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }

}
