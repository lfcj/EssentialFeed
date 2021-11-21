import XCTest
@testable import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHttpClient {
    private let session: HTTPSession

    init(session: HTTPSession) {
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

    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = HTTPSessionTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHttpClient(session: session)
        sut.get(from: url) { _ in }
        XCTAssertEqual(task.resumeCallCount, 1)
    }

    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://any-url.com")!
        let session = HTTPSessionSpy()
        let task = HTTPSessionTaskSpy()
        let stubError = NSError(domain: "Any error", code: 1)
        session.stub(url: url, error: stubError)
        let sut = URLSessionHttpClient(session: session)
        let exp = expectation(description: "Wait for get(from:url) completion")
        sut.get(from: url) { result in
            guard case .failure(let receivedError as NSError) = result else {
                XCTFail("Expected error with failure \(stubError). Got result \(result)")
                return
            }
            XCTAssertEqual(stubError, receivedError)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

}

private class HTTPSessionSpy: HTTPSession {

    private struct Stub {
        let task: HTTPSessionTask
        let error: Error?
    }

    private var stubs: [URL: Stub] = [:]

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
        guard let stub = stubs[url] else {
            fatalError("Stub spy before calling it, url: \(url)")
        }
        completionHandler(nil, nil, stub.error)
        return stub.task
    }

    func stub(url: URL, task: HTTPSessionTask = FakeHTTPSessionTask(), error: Error? = nil) {
        stubs[url] = Stub(task: task, error: error)
    }

}

private class FakeHTTPSessionTask: HTTPSessionTask {
    func resume() {}
}
private class HTTPSessionTaskSpy: HTTPSessionTask {
    private(set) var resumeCallCount = 0

    func resume() {
        resumeCallCount += 1
    }
}
