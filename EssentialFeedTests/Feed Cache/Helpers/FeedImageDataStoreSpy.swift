import EssentialFeed
import Foundation

final class FeedImageDataStoreSpy: FeedImageDataStore {

    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }

    private var completions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private(set) var receivedMessages = [Message]()
    private var insertionResult: Result<Void, Error>?

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completions.append(completion)
        receivedMessages.append(.retrieve(dataFor: url))
    }

    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}

    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }

    func complete(with data: Data?, at index: Int = 0) {
        completions[index](.success(data))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }

}
