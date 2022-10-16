import Foundation

public final class FeedImagePresenter<Image> {

    public static func map(_ feedImage: FeedImage) -> FeedImageViewModel<Image> {
        FeedImageViewModel( 
            isLocationContainerHidden: feedImage.location == nil,
            location: feedImage.location,
            description: feedImage.description,
            feedImage: nil,
            isLoading: false,
            isRetryButtonHidden: false
        )
    }

}
