import XCTest

class URLSessionHttpClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        let dataTask = session.dataTask(with: url) { _, _, _ in }
        dataTask.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHttpClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(session.receivedURLs, [url])
    }

    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHttpClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(session.receivedURLs, [url])
    }

}

private class URLSessionSpy: URLSession {

    var receivedURLs: [URL] = []
    var stubs: [URL: URLSessionDataTask] = [:]

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        receivedURLs.append(url)
        return stubs[url] ?? FakeURLSessionDataTask()
    }

    func stub(url: URL, task: URLSessionDataTask) {
        stubs[url] = task
    }

}

private class FakeURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
}
private class URLSessionDataTaskSpy: URLSessionDataTask {
    private(set) var resumeCallCount = 0

    override func resume() {
        resumeCallCount += 1
    }
}
