@testable import EssentialFeed
import EssentialFeediOS
import XCTest

final class FeedSnapshotTests: XCTestCase {
 
    func test_emptyFeed() {
        let sut = makeSUT()

        sut.display(emptyFeed())

        assert(snapshot: sut.snapshot(), named: "FEED_EMPTY")
    }

    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }

    func test_feedWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is\na multiline\nerror"))

        assert(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR")
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
    }

}

// MARK: - Helpers

private extension FeedSnapshotTests {

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        trackForMemoryLeaks(controller)
        controller.loadViewIfNeeded()
        return controller
    }

    func emptyFeed() -> [FeedImageCellController] {
        []
    }

    func feedWithContent() -> [ImageStub] {
        [
            ImageStub(
                description: "Awesome place",
                location: "Berlin",
                image: UIImage.make(color: .red)
            ),
            ImageStub(
                description: "Different place",
                location: "London",
                image: UIImage.make(color: .green)
            )
        ]
    }

    func feedWithFailedImageLoading() -> [ImageStub] {
        [
            ImageStub(
                description: "Awesome place",
                location: "Berlin",
                image: nil
            ),
            ImageStub(
                description: "Different place",
                location: "London",
                image: nil
            )
        ]
    }

    func record(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotData = makeSnapshotData(snapshot: snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(name: name, file: file)

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to save image \(name). Error: \(error))", file: file, line: line)
        }
    }

    func assert(
        snapshot: UIImage,
        named name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotData = makeSnapshotData(snapshot: snapshot, file: file, line: line)
        let snapshotURL = makeSnapshotURL(name: name, file: file)

        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail(
                "Failed to read the data at \(snapshotURL). Record it first with `record(..)`",
                file: file,
                line: line
            )
            return
        }

        if storedSnapshotData != snapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)

            try? snapshotData?.write(to: temporarySnapshotURL)

            XCTFail(
                "Snapshot \(name) is not equal stored one. New URL: \(temporarySnapshotURL). Stored one: \(snapshotURL)",
                file: file,
                line: line
            )
        }
    }

    func makeSnapshotData(
        snapshot: UIImage,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to get PNG image from \(name).", file: file, line: line)
            return nil
        }

        return snapshotData
    }

    func makeSnapshotURL(name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png", isDirectory: false)
    }

}

extension UIViewController {

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }

}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        display(cells)
    }
}

private final class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?

    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(
            isLocationContainerHidden: location == nil,
            location: location,
            description: description,
            feedImage: image,
            isLoading: false,
            isRetryButtonHidden: image != nil
        )
    }

    func didRequestImageDataLoad() {
        controller?.display(viewModel)
    }
    func didRequestCancellingImageDataLoad() {}

}

extension UIImage {

    static func make(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

}
