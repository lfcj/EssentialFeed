import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    public static func feedComposed(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedLoaderDecorator = MainQueueDispatchDecorator(decoratee: feedLoader)
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoaderDecorator)

        let feedViewController = makeFeedViewController(delegate: feedLoaderPresentationAdapter, title: FeedPresenter.title)
        let imageLoaderDecorator = MainQueueDispatchDecorator(decoratee: imageLoader)
        feedLoaderPresentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedViewController, loader: imageLoaderDecorator),
            loadingView: WeakRefVirtualProxy(feedViewController),
            errorView: WeakRefVirtualProxy(feedViewController)
        )
        return feedViewController
    }

    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.title = title
        feedViewController.delegate = delegate

        return feedViewController
    }

}
