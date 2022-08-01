@testable import EssentialFeed
import EssentialFeediOS
import XCTest

final class FeedSnapshotTests: XCTestCase {
 
    func test_emptyFeed() {
        let sut = makeSUT()

        sut.display(emptyFeed())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_EMPTY_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_EMPTY_dark")
    }

    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
    }

    func test_feedWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is\na multiline\nerror"))

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_dark")
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }

}

// MARK: - Helpers

private extension FeedSnapshotTests {

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
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
                "Snapshot \(name) is not equal stored one. New URL: \(temporarySnapshotURL). Stored one: \(snapshotURL)"
                + "Stored one size: \(storedSnapshotData.count). New one size: \(String(describing: snapshotData?.count))",
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

    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }

}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
        SnapshotConfiguration(
            size: CGSize(width: 375, height: 667),
            safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: UITraitCollection(
                traitsFrom: [
                    .init(forceTouchCapability: .available),
                    .init(layoutDirection: .leftToRight),
                    .init(preferredContentSizeCategory: .medium),
                    .init(userInterfaceIdiom: .phone),
                    .init(horizontalSizeClass: .compact),
                    .init(verticalSizeClass: .regular),
                    .init(displayScale: 2),
                    .init(displayGamut: .P3),
                    .init(userInterfaceStyle: style)
                ]
            )
        )
    }
}

final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone8(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format:  UIGraphicsImageRendererFormat(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
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
