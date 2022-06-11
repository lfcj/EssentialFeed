import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}
public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    typealias SaveResult = Swift.Result<Void, Swift.Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
