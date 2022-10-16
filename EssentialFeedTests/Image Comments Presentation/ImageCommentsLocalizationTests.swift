import EssentialFeed
import XCTest

final class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Comments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)

        assertLocalizedKeysAndValuesExist(in: bundle, table)
    }

}
