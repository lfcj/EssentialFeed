import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

// MARK: - ManagedCache Helpers

extension ManagedCache {
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(
            array: localFeed.map { local in
                let managed = ManagedFeedImage(context: context)
                managed.id = local.id
                managed.imageDescription = local.description
                managed.location = local.location
                managed.url = local.url
                return managed
            }
        )
    }
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try deleteCache(in: context)
        return ManagedCache(context: context)
    }
    static func deleteCache(in context: NSManagedObjectContext) throws {
        try find(in: context).map(context.delete).map(context.save)
    }
    var localFeed: [LocalFeedImage] { feed.compactMap { ($0 as? ManagedFeedImage)?.local } }
}
