import EssentialFeed
import XCTest

final class FeedImagePresenterTests: XCTestCase {

    func test_map_createsViewModel()  {
        let image =  uniqueImage()

        let viewModel = FeedImagePresenter<FakeImage>.map(image)

        XCTAssertEqual(viewModel.location, image.location)
        XCTAssertEqual(viewModel.description, image.description)
    }

    // MARK: - Helpers

    private struct FakeImage: Hashable {
        let data: Data
    }

}
