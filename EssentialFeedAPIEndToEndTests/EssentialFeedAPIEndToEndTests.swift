import EssentialFeed
import XCTest

class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETFeedResult_matchesFixedTestsAccountData() {
        let testServerURL = URL(string: "https://www.essentialdeveloper.com/s/feed-case-study-test-api-feed.json")!
        let client = URLSessionHttpClient()
        let loader = RemoteFeedLoader(url: testServerURL, client: client)

        let exp = expectation(description: "Wait for load completion")
        var receivedResult: LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5)

        switch receivedResult {
        case .success(let items):
            XCTAssertEqual(items.count, 8, "Expected 8 items")
        case .failure(let error):
            XCTFail("Expected successful feed result and got an error: \(error)")
        case .none:
            XCTFail("Expected successful feed result and got nothing")
        }
    }

}
