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
    @Published var showClearConfirm = false
    @Published var sessions: [ChatSession] = []
    private var activeSessionID: UUID? = nil

    func makeSessionActive(id: UUID){
        if sessions.contains(where: {$0.id == id}) {
            activeSessionID = id
        }
    }
    
    func getActiveSessionMessages() -> [Message] {
        if activeSessionID != nil{
            if let activeSession = sessions.first(where: {$0.id == activeSessionID!}) {
                return activeSession.messages
            }
        }
        return []
    }
    
    func updateActiveSession(messages: [Message]) {
        if activeSessionID != nil{
            if let idx = sessions.firstIndex(where: {$0.id == activeSessionID!}) {
                sessions[idx].messages = messages
            }
        } else {
            self.saveSession(messages: messages, category: nil)
        }
    }
    
    func closeActiveSession() {
        activeSessionID = nil
    }
    
    func hasActiveSession() -> Bool {
        return activeSessionID != nil
    }
    
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
