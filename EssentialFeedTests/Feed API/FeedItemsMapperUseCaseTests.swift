import XCTest
import EssentialFeed

class FeedItemsMapperUseCaseTests: XCTestCase {

    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, from: makeHTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("Invalid json".utf8)
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, from: makeHTTPURLResponse(statusCode: 200))
        )
    }

    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let emptyJSON = makeItemsJSON([])

        XCTAssertEqual(try FeedItemsMapper.map(emptyJSON, from: makeHTTPURLResponse(statusCode: 200)), [])
    }

    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() {
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "a desc", location: "a loc", imageURL: URL(string: "https://another-url.com")!)

        let items = [item1.model, item2.model]
        let jsonData = makeItemsJSON([item1.json, item2.json])

        XCTAssertEqual(try FeedItemsMapper.map(jsonData, from: makeHTTPURLResponse(statusCode: 200)), items)
    }

    // MARK: - Helpers

    private func makeItem(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL) -> (model: FeedImage, json: [String: Any])
    {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json: [String: Any] = [
            "id": id.uuidString,
            "description": description,// ?? "null",
            "location": location,// ?? "null",
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }

}

