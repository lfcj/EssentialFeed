import Foundation

public final class FeedItemsMapper {

    public enum Error: Swift.Error {
        case invalidData
    }

    private struct FeedItemResult: Decodable {
        private let items: [RemoteFeedItem]
        private struct RemoteFeedItem: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        var images: [FeedImage] {
            items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK, let result = try? JSONDecoder().decode(FeedItemResult.self, from: data) else {
            throw Error.invalidData
        }

        return result.images
    }

}
