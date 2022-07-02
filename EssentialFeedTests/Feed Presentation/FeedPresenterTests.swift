import XCTest

final class FeedPresenter {

    init(view: Any) {}

}

final class FeedPresenterTests: XCTestCase {

    func test_feedPresenter_doesNotSendAnythingOnInitialisation() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages")
    }

    private class ViewSpy {
        private(set) var messages: [Any] = []
    }

}
