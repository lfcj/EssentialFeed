import Foundation

final class FeedItemsMapper {

    private struct FeedItemResult: Decodable {
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK, let result = try? JSONDecoder().decode(FeedItemResult.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return result.items
    }

}
