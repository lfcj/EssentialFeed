import Foundation

public final class ImageCommentsPresenter {

    public static let title = NSLocalizedString(
        "COMMENTS_VIEW_TITLE",
        tableName: "Comments",
        bundle: Bundle(for: ImageCommentsPresenter.self),
        comment: "Title for the image comments view"
    )

    public static func map(
        _ comments: [ImageComment],
        calendar: Calendar = .current,
        locale: Locale = .current,
        currentDate: Date = Date()
    ) -> [ImageCommentViewModel] {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale

        return comments.map { comment in
            ImageCommentViewModel(
                message: comment.message,
                createAtMessage: formatter.localizedString(for: comment.createdDate, relativeTo: currentDate),
                username: comment.username
            )
        }
    }

}
