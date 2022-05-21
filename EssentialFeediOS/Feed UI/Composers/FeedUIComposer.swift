import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    public static func feedComposed(with feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedLoaderDecorator = MainQueueDispatchDecorator(decoratee: feedLoader)
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoaderDecorator)

        let feedViewController = FeedViewController.makeWith(delegate: feedLoaderPresentationAdapter, title: FeedPresenter.title)
        let imageLoaderDecorator = MainQueueDispatchDecorator(decoratee: imageLoader)
        feedLoaderPresentationAdapter.presenter = FeedPresenter(
            feedView: FeedViewAdapter(controller: feedViewController, loader: imageLoaderDecorator),
            loadingView: WeakRefVirtualProxy(feedViewController)
        )
        return feedViewController
    }
}

private final class MainQueueDispatchDecorator<T> {
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
    func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
        decoratee.load { [weak self] result in
            self?.distach { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.distach { completion(result) }
        }
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.title = title
        feedViewController.delegate = delegate

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
