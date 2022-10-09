import Foundation

public struct ImageComment: Equatable {
    public let id: UUID
    public let message: String
    public let createdDate: Date
    public let username: String

    public init(id: UUID, message: String, createdDate: Date, username: String) {
        self.id = id
        self.message = message
        self.createdDate = createdDate
        self.username = username
    }
}
