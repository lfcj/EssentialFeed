import EssentialFeed
import Foundation

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    typealias ImageTransformer = (Data) -> Image?

    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: ImageTransformer

    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping ImageTransformer) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }

    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?

    var description: String? { model.description }
    var location: String? { model.location }
    var hasLocation: Bool { model.location != nil }

    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }

    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }

    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }

}
