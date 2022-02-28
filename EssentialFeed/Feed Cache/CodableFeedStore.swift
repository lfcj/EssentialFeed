import Foundation

public final class CodableFeedStore: FeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
    }
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        init(_ localFeed: LocalFeedImage) {
            self.id = localFeed.id
            self.description = localFeed.description
            self.location = localFeed.location
            self.url = localFeed.url
        }

        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.empty))
            }

            do {
                let foundCachedData = try JSONDecoder().decode(Cache.self, from: data)
                completion(.success(.found(feed: foundCachedData.feed.map { $0.local }, timestamp: foundCachedData.timestamp)))
            } catch (let error) {
                completion(.failure(error))
            }
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            let encoder = JSONEncoder()
            let codableCache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
            let encoded = try! encoder.encode(codableCache)
            do {
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }

}
