import EssentialFeed
import UIKit

public protocol FeedImageDataLoaderTask {
    func cancel()
}
public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public final class FeedViewController: UITableViewController {

    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]()
    private var imageLoadingTasks = [IndexPath: FeedImageDataLoaderTask]()

    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.locationLabel.text = cellModel.location
        cell.descriptionLabel.text = cellModel.description
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        imageLoadingTasks[indexPath] = imageLoader?.loadImageData(from: cellModel.url) { [weak cell] result in
            if let data = try? result.get(), let image = UIImage(data: data) {
                cell?.feedImageView.image = image
            }
            cell?.feedImageContainer.stopShimmering()
        }
        return cell
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageLoadingTasks[indexPath]?.cancel()
        imageLoadingTasks[indexPath] = nil
    }

    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }

}
