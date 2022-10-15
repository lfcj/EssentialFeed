import EssentialFeed
import XCTest

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyResourceView>.self)

        assertLocalizedKeysAndValuesExist(in: bundle, table)
    }

    private class DummyResourceView: ResourceView {
        func display(_ viewModel: Any) {}
    }

}
