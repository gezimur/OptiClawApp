import Foundation

struct Message: Identifiable, Equatable, Codable {
    let id: Int
    let content: String
    let isUser: Bool
    var imagePath: String?
    let timestamp: Date

    init(id: Int, content: String, isUser: Bool, imagePath: String? = nil) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.imagePath = imagePath
        self.timestamp = Date()
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}
