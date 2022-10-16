import EssentialFeed
import XCTest

final class ImageCommentsPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("COMMENTS_VIEW_TITLE"))
    }

    func test_map_createsViewModel() {
        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdDate: Date().adding(seconds: -5),
                username: "a user"
            ),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdDate: Date().adding(days: -1),
                username: "another user"
            )
        ]

        let commentViewModels = ImageCommentsPresenter.map(comments)

        let firstMessageViewModel = commentViewModels[0]
        XCTAssertEqual(firstMessageViewModel.message, "a message")
        XCTAssertEqual(firstMessageViewModel.createAtMessage, "5 seconds ago")
        XCTAssertEqual(firstMessageViewModel.username, "a user")

        let secondMessageViewModel = commentViewModels[1]
        XCTAssertEqual(secondMessageViewModel.message, "another message")
        XCTAssertEqual(secondMessageViewModel.createAtMessage, "1 day ago")
        XCTAssertEqual(secondMessageViewModel.username, "another user")
    }

    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Comments"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing value for key: \(key) in table: \(table)", file: file, line: line)
        }

        return value
    }

}
