import Foundation

struct ChatSession: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
    let date: Date
    var messages: [Message]

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

@MainActor
class ChatHistoryManager: ObservableObject {
    @Published var sessions: [ChatSession] = []

    func saveSession(messages: [Message], category: ChatCategory?) {
        guard !messages.isEmpty else { return }
        let title = category?.rawValue ?? messages.first(where: { $0.isUser })?.content.prefix(40).description ?? "New Chat"
        let preview = messages.last?.content.prefix(80).description ?? ""
        let session = ChatSession(title: title, preview: String(preview), date: Date(), messages: messages)
        sessions.insert(session, at: 0)
    }

    func deleteSession(_ session: ChatSession) {
        sessions.removeAll { $0.id == session.id }
    }

    func clearAll() {
        sessions.removeAll()
    }
}
