@testable import EssentialFeed
import EssentialFeediOS
import XCTest

final class ImageCommentsSnapshotTests: XCTestCase {
    
    func test_listWithComments() {
        let sut = makeSUT()

        sut.display(comments())
  
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
//        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
    }

}

// MARK: - Helpers

private extension ImageCommentsSnapshotTests {

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        trackForMemoryLeaks(controller)
        controller.loadViewIfNeeded()
        return controller
    }

    func comments() -> [CellController] {
        [
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: """
                        First message First message First message First message First message First message First message First message First message First message First message
                    """,
                    createAtMessage: "5 hours ago",
                    username: "A long long long long user user user user user"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "Second message Second message Second message",
                    createAtMessage: "1 minute ago",
                    username: "Another user"
                )
            ),
            ImageCommentCellController(
                model: ImageCommentViewModel(
                    message: "Third",
                    createAtMessage: "now",
                    username: "User"
                )
            )
        ]
    }

}

