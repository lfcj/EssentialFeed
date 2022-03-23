import EssentialFeed
import Foundation
import UIKit

public final class FeedRefreshViewController: NSObject {

    typealias RefreshHandler = ([FeedImage]) -> Void

    var onRefresh: RefreshHandler?

    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    private let feedLoader: FeedLoader

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    @objc func refresh() {
        view.beginRefreshing()
        feedLoader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
