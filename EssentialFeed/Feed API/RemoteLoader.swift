import Foundation

public final class RemoteLoader<Resource> {
    private let url: URL
    private let client: HTTPClient
    private let mapper: Mapper

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    public typealias Result = Swift.Result<Resource, Swift.Error>

    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else {
                return
            }
            // The RemoteFeedLoader maps client errors to domain errors.
            switch result {
            case let .success((data, response)):
                completion(self.map(data: data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private func map(data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try mapper(data, response)
            return .success(items)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
