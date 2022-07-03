import EssentialFeed
import XCTest

final class FeedImagePresenter {
    init(view: Any) {
        
    }
}

final class FeedImagePresenterTests: XCTestCase {

    func test_feedImagePresenter_doesNotSendMessagesWhenInstantiated() {
        let view = ViewSpy()
        let _ = FeedImagePresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty)
    }

    // MARK: - Helpers

    private class ViewSpy {
        let messages: [Any] = []
    }
}
