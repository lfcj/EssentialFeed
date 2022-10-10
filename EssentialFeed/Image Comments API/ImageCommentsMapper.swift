import Foundation

public final class ImageCommentsMapper {

    private struct FeedItemResult: Decodable {
        var comments: [ImageComment] {
            items.map { ImageComment(id: $0.id, message: $0.message, createdDate: $0.created_at, username: $0.author.username) }
        }
        private let items: [Item]

        private struct Item: Decodable {
            let id: UUID
            let message: String
            let created_at: Date
            let author: Author
        }
        private struct Author: Decodable {
            let username: String
        }
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard isOK(response), let result = try? decoder.decode(FeedItemResult.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return result.comments
    }

    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode >= 200 && response.statusCode < 300
    }

}
