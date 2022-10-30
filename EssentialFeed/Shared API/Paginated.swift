import Foundation

public struct Paginated<Item> {
    public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void
    
    public let items: [Item]
    public let loadMoreHandler: ((@escaping LoadMoreCompletion) -> Void)?
    
    public init(items: [Item], loadMoreHandler: ((@escaping LoadMoreCompletion) -> Void)? = nil) {
        self.items = items
        self.loadMoreHandler = loadMoreHandler
    }
}
