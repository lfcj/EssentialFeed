import Foundation

public final class ImageCommentsPresenter {

    public static let title = NSLocalizedString(
        "COMMENTS_VIEW_TITLE",
        tableName: "Comments",
        bundle: Bundle(for: ImageCommentsPresenter.self),
        comment: "Title for the image comments view"
    )

    public static func map(_ comments: [ImageComment]) -> [ImageCommentViewModel] {
        let formatter = RelativeDateTimeFormatter()
        return comments.map { comment in
            ImageCommentViewModel(
                message: comment.message,
                createAtMessage: formatter.localizedString(for: comment.createdDate, relativeTo: Date()),
                username: comment.username
            )
        }
    }

}
