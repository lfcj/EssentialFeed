import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

// MARK: - ManagedFeedImage Extension

extension ManagedFeedImage {
    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }

    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        request .returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        try first(with: url, in: context)?.data
    }
}
