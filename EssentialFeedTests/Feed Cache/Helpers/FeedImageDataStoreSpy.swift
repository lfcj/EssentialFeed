import EssentialFeed
import Foundation

final class FeedImageDataStoreSpy: FeedImageDataStore {

    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }

    private(set) var receivedMessages = [Message]()
    private var retrievalResult: Result<Data?, Error>?
    private var insertionResult: Result<Void, Error>?

    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMessages.append(.retrieve(dataFor: url))
        return try retrievalResult?.get()
    }

    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }

    func complete(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }

    func complete(with data: Data?, at index: Int = 0) {
        retrievalResult = .success(data)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }

}
