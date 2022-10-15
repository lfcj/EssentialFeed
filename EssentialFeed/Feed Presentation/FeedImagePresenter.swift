import Foundation

public protocol FeedImageView {
    associatedtype Image
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {

    public typealias ImageTransformer = (Data) -> Image?

    private struct InvalidImageDataError: Error {}

    private let feedImageView: View
    private let imageTransformer: ImageTransformer

    public init(feedImageView: View, imageTransformer: @escaping ImageTransformer) {
        self.feedImageView = feedImageView
        self.imageTransformer = imageTransformer
    }

    public static func map(_ feedImage: FeedImage) -> FeedImageViewModel<FeedImage> {
        FeedImageViewModel( 
            isLocationContainerHidden: feedImage.location == nil,
            location: feedImage.location,
            description: feedImage.description,
            feedImage: nil,
            isLoading: false,
            isRetryButtonHidden: false
        )
    }

    public func didStartLoadingImage(for model: FeedImage) {
        feedImageView.display(
            makeFeedImageViewModel(
                model: model,
                feedImage: nil,
                isLoading: true,
                isRetryButtonHidden: true
            )
        )
    }

    public func didFinishLoadingImageData(_ imageData: Data, with model: FeedImage) {
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

    public func didFinishLoadingImageData(with error: Error, model: FeedImage) {
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
