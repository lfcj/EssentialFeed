import EssentialFeed
import Foundation

protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}
final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {

    typealias ImageTransformer = (Data) -> Image?

    private let feedImageView: View
    private let imageTransformer: ImageTransformer
    
    init(feedImageView: View, imageTransformer: @escaping ImageTransformer) {
        self.feedImageView = feedImageView
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImage(for model: FeedImage) {
        feedImageView.display(
            makeFeedImageViewModel(
                model: model,
                feedImage: nil,
                isLoading: true,
                isRetryButtonHidden: true
            )
        )
    }

    private struct InvalidImageDataError: Error {}

    func didFinishLoadingImageData(_ imageData: Data, with model: FeedImage) {
        guard let image = imageTransformer(imageData) else {
            didFinishLoadingImageData(with: InvalidImageDataError(), model: model)
            return
        }
        feedImageView.display(
            makeFeedImageViewModel(
                model: model,
                feedImage: image,
                isLoading: false,
                isRetryButtonHidden: true
            )
        )
    }

    func didFinishLoadingImageData(with error: Error, model: FeedImage) {
        feedImageView.display(
            makeFeedImageViewModel(
                model: model,
                feedImage: nil,
                isLoading: false,
                isRetryButtonHidden: false
            )
        )
    }

    private func makeFeedImageViewModel(model: FeedImage, feedImage: Image?, isLoading: Bool, isRetryButtonHidden: Bool) -> FeedImageViewModel<Image> {
        FeedImageViewModel(
            isLocationContainerHidden: model.location == nil,
            location: model.location,
            description: model.description,
            feedImage: feedImage,
            isLoading: isLoading,
            isRetryButtonHidden: isRetryButtonHidden
        )
    }

}
