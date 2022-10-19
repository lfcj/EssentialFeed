import Foundation

public final class FeedImagePresenter<Image> {

    public static func map(_ feedImage: FeedImage) -> FeedImageViewModel<Image> {
        FeedImageViewModel(location: feedImage.location, description: feedImage.description)
    }

}
