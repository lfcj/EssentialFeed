import Foundation

public final class LocalFeedImageDataLoader {

    private let store: Any

    public init(store: Any) {
        self.store = store
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        
    }
}
