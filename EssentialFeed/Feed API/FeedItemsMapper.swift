import Foundation

final class FeedItemsMapper {

    private struct FeedItemResult: Decodable {
        let items: [Item]
        var feed: [FeedItem] {
            items.map { $0.item }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static var OK_200: Int { 200 }

    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let result = try? JSONDecoder().decode(FeedItemResult.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(result.feed)
    }

}

