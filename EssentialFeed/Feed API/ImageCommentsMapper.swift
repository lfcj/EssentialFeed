import Foundation

final class ImageCommentsMapper {

    private struct FeedItemResult: Decodable {
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard isOK(response), let result = try? JSONDecoder().decode(FeedItemResult.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return result.items
    }

    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode >= 200 && response.statusCode < 300
    }

}
