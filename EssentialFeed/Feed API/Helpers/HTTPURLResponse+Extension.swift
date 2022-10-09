import Foundation

extension HTTPURLResponse {
    var isOK: Bool {
        statusCode == 200
    }
}
