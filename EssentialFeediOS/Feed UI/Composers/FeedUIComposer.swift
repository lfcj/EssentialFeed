import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    public static func feedComposed(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)

        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.title = FeedPresenter.title
        feedViewController.delegate = feedLoaderPresentationAdapter

        feedLoaderPresentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedViewController, loader: imageLoader),
            loadingView: WeakRefVirtualProxy(feedViewController)
        )
        return feedViewController
    }
}

private class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView {
    func display(_ viewModel: FeedImageViewModel<T.Image>) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader

    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let imagePresentationAdapter = FeedImagerLoaderPresentationAdapter(feedImageLoader: loader, model: model)
            let feedCellController = FeedImageCellController(delegate: imagePresentationAdapter)
            imagePresentationAdapter.presenter = FeedImagePresenter(
                feedImageView: WeakRefVirtualProxy(feedCellController),
                imageTransformer: UIImage.init
            )
            return feedCellController
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    var presenter: FeedPresenter?
    private let feedLoader: FeedLoader
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class FeedImagerLoaderPresentationAdapter: FeedImageCellControllerDelegate {
    var presenter: FeedImagePresenter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>?
    private let feedImageLoader: FeedImageDataLoader
    private let model: FeedImage

    private var task: FeedImageDataLoaderTask?

    init(feedImageLoader: FeedImageDataLoader, model: FeedImage) {
        self.feedImageLoader = feedImageLoader
        self.model = model
    }

    func didRequestImageDataLoad() {
        presenter?.didStartLoadingImage(for: model)
        task = feedImageLoader.loadImageData(from: model.url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(imageData):
                self.presenter?.didFinishLoadingImageData(imageData, with: self.model)
            case let .failure(error):
                self.presenter?.didFinishLoadingImageData(with: error, model: self.model)
            }
        }
    }

    func didRequestCancellingImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
