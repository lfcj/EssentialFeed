@testable import EssentialFeed
import EssentialFeediOS
import XCTest

final class ListSnapshotTests: XCTestCase {
    
    func test_emptyFeed() {
        let sut = makeSUT()
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_EMPTY_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_EMPTY_dark")
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_EMPTY_light")
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_EMPTY_dark")
    }

    func test_feedWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is\na multiline\nerror"))

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_ERROR_extraExtraExtraLarge_light")
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_light")
//        record(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_dark")
    }

}

// MARK: - Helpers

private extension ListSnapshotTests {

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> ListViewController {
        let controller = ListViewController()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.tableView.separatorStyle = .none
        trackForMemoryLeaks(controller)
        controller.loadViewIfNeeded()
        return controller
    }

    func emptyFeed() -> [CellController] {
        []
    }

}
