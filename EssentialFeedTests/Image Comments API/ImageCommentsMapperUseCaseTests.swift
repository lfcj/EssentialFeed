import XCTest
import EssentialFeed

final class ImageCommentsMapperUseCaseTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let samples = [199, 150, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(makeItemsJSON([]), from: makeHTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let invalidJSON = Data("Invalid json".utf8)
        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, from: makeHTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
        let emptyJSON = makeItemsJSON([])
        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            XCTAssertEqual(try ImageCommentsMapper.map(emptyJSON, from: makeHTTPURLResponse(statusCode: code)), [])
        }
    }

    func test_map_deliversItemsOn2xxHTTPResponseWithJSONItems() throws {
        let comment1 = makeItem(
            id: UUID(),
            message: "message 1",
            createdAt: (date: Date(timeIntervalSince1970: 1598627222), iso8601String: "2020-08-28T15:07:02+00:00"),
            username: "user"
        )
        let comment2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (date: Date(timeIntervalSince1970: 1577881882), iso8601String: "2020-01-01T12:31:22+00:00"),
            username: "another user"
        )

        let comments = [comment1.model, comment2.model]
        let samples = [200, 201, 250, 280, 299]
        let jsonData = makeItemsJSON([comment1.json, comment2.json])

        try samples.forEach { code in
            XCTAssertEqual(try ImageCommentsMapper.map(jsonData, from: makeHTTPURLResponse(statusCode: code)), comments)
        }
    }

    // MARK: - Helpers

    private func makeItem(
        id: UUID,
        message: String,
        createdAt dateAndDateString: (date: Date, iso8601String: String),
        username: String
    ) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdDate: dateAndDateString.date, username: username)
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": dateAndDateString.iso8601String,
            "author": [
                "username": username
            ]
        ]

        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON)
    }

}
