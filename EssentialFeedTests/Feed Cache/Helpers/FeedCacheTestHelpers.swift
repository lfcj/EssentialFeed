import EssentialFeed
import Foundation

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (models, local)
}

extension Date {

    private var feedCacheMaxAgeInDays: Int { 7 }

    func minusFeedCacheMaxAge() -> Date {
        adding(days: -feedCacheMaxAgeInDays)
    }

    func adding(seconds: TimeInterval) -> Date  {
        self + seconds
    }
}
extension Date {

    private func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day , value: days, to: self)!
    }

}
