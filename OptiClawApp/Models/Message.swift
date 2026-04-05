import Foundation
import UIKit

struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    var image: UIImage?
    let timestamp: Date

    init(content: String, isUser: Bool, image: UIImage? = nil) {
        self.content = content
        self.isUser = isUser
        self.image = image
        self.timestamp = Date()
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}
