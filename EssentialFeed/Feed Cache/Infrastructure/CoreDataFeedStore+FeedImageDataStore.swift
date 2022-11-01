import Foundation

extension CoreDataFeedStore: FeedImageDataStore {

    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        do {
            try insert(data, for: url)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        do {
            let retrievedData = try retrieve(dataForURL: url)
            completion(.success(retrievedData))
        } catch {
            completion(.failure(error))
        }
    }

    public func insert(_ data: Data, for url: URL) throws {
        try performSync { context in
            Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            }
        }
    }

    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync { context in
            Result {
                try ManagedFeedImage.data(with: url, in: context)
            }
        }
    }

}
