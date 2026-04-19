import Foundation

struct ChatSession: Identifiable, Codable {
    let id: Int
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
    private var activeSessionID: Int? = nil

    func makeSessionActive(id: Int){
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
    
    func closeActiveSession() {
        activeSessionID = nil
    }
    
    func updateActiveSession(messages: [Message]) {
        guard !messages.isEmpty else { return }
        
        if activeSessionID != nil{
            if let sessionIdx = sessions.firstIndex(where: {$0.id == activeSessionID!}) {
                if (sessions[sessionIdx].messages.isEmpty) {
                    sessions[sessionIdx].messages = messages
                    cacheSession(sessionIdx: sessionIdx)
                } else {
                    let idx = messages.firstIndex(where: {$0.timestamp > sessions[sessionIdx].messages.last!.timestamp})
                    if (idx != nil) {
                        sessions[sessionIdx].messages += messages[idx!..<messages.count]
                        cacheSession(sessionIdx: sessionIdx)
                    }
                }
                
            }
        } else {
            let sessionIdx = self.saveSession(messages: messages, category: nil)
            if (sessionIdx >= 0) {
                cacheSession(sessionIdx: sessionIdx)
            }
        }
    }
    
    func hasActiveSession() -> Bool {
        return activeSessionID != nil
    }

    func deleteSession(_ session: ChatSession) {
        sessions.removeAll { $0.id == session.id }
    }

    func clearAll() {
        sessions.removeAll()
    }
    
    init() {
        self.showClearConfirm = false
        
        self.sessions = []
        
        var nextSession: ChatSession? = CacheManager.shared.get(key: "sessions/" + self.sessions.count.description)
        while (nextSession != nil){
            self.sessions.append(nextSession!)
            nextSession = CacheManager.shared.get(key: "sessions/" + self.sessions.count.description)
        }
        self.activeSessionID = nil
    }
    
    private func saveSession(messages: [Message], category: ChatCategory?) -> Int{
        guard !messages.isEmpty else { return -1}
        let title = category?.rawValue ?? messages.first(where: { $0.isUser })?.content.prefix(40).description ?? "New Chat"
        let preview = messages.last?.content.prefix(80).description ?? ""
        let session = ChatSession(id: sessions.count, title: title, preview: String(preview), date: Date(), messages: messages)
        sessions.append(session)
        return session.id
    }
    
    private func cacheSession(sessionIdx: Int) {
        CacheManager.shared.set(key: "sessions/" + sessionIdx.description, value: sessions[sessionIdx])
        print("Cache session: " + sessionIdx.description)
    }
}
