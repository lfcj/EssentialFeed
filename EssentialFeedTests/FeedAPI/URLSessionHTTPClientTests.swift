import XCTest
@testable import EssentialFeed

class URLSessionHttpClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else if let error = error {
                completion(.failure(error))
            } else {
                //fatalError("request to url \(url) has invalid response: \(response)")
            }
        }
        dataTask.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "https://any-url.com")!
        let stubError = NSError(domain: "Any error", code: 1)
        URLProtocolStub.stub(url: url, error: stubError)
        let sut = URLSessionHttpClient()
        let exp = expectation(description: "Wait for get(from:url) completion")
        sut.get(from: url) { result in
            guard case .failure(let receivedError as NSError) = result else {
                XCTFail("Expected error with failure \(stubError). Got result \(result)")
                return
            }
            XCTAssertEqual(stubError, receivedError.userInfo)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }

}

private class URLProtocolStub: URLProtocol {

    private struct Stub {
        let error: Error?
    }

    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

    private static var stubs: [URL: Stub] = [:]

    static func stub(url: URL, error: Error? = nil) {
        stubs[url] = Stub(error: error)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }
        return stubs[url] != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url, let stub = Self.stubs[url] else {
            return
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

}
