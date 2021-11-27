import Foundation

extension URLSession: HTTPClient {

    private struct UnexpectedValuesRepresentation: Error {}

    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let dataTask = dataTask(with: url) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }
        dataTask.resume()
    }
}
