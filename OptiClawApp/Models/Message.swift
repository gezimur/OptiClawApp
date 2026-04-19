import Foundation

struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    var imagePath: String?
    let timestamp: Date

    init(content: String, isUser: Bool, imagePath: String? = nil) {
        self.content = content
        self.isUser = isUser
        self.imagePath = imagePath
        self.timestamp = Date()
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}
