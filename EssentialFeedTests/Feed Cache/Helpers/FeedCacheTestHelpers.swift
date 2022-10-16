import EssentialFeed
import Foundation

func uniqueImage(location: String? = "any", description: String? = "any") -> FeedImage {
    FeedImage(id: UUID(), description: description, location: location, url: anyURL())
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

    func adding(seconds: TimeInterval, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date  {
        // self + seconds // Left as a comment to remember one can add and substract seconds to `Date`
        calendar.date(byAdding: .second , value: Int(seconds), to: self)!
    }

    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .day , value: days, to: self)!
    }

}
