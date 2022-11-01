import CoreData

public final class CoreDataFeedStore: FeedStore {

    enum StoreError: Error{
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    private static let modelName = "FeedStore2"

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL) throws {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        guard let model = NSManagedObjectModel.with(name: Self.modelName, in: bundle) else {
            throw StoreError.modelNotFound
        }

        do {
            container = try NSPersistentContainer.load(name: Self.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion(
                Result {
                    try ManagedCache.find(in: context).map {
                        return CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                    }
                }
            )
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            completion(
                Result {
                    let managedCache = try ManagedCache.newUniqueInstance(in: context)
                    managedCache.timestamp = timestamp
                    managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                    try context.save()
                }
            )
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(
                Result {
                    try ManagedCache.deleteCache(in: context)
                }
            )
        }
    }

    func performAsync(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }

    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }

    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }

}
