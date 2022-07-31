import EssentialFeediOS
import XCTest

final class FeedSnapshotTests: XCTestCase {
 
    func test_emptyFeed() {
        let sut = makeSUT()

        sut.display(emptyFeed())

        record(snapshot: sut.snapshot(), name: "FEED_EMPTY")
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

    func record(snapshot: UIImage, name: String, file: StaticString = #file, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to get PNG image from \(name).", file: file, line: line)
            return
        }

        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png", isDirectory: false)

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to save image \(name). Error: \(error))", file: file, line: line)
        }
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
