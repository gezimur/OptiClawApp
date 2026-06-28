import Foundation
import SwiftUI
import StoreKit

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping = false
    @Published var showNewChatSheet = false
    @Published var showAttachmentSheet = false
    @Published var showCopiedToast = false
    @Published var networkError: String?
    @Published var selectedCategory: ChatCategory?
    @Published var showPaywall = false
    @Published var isProUser = false

    private let freeMessageLimit = 3
    var userMessageCount: Int { messages.filter(\.isUser).count }

    private var subscriptionTask: Task<Void, Never>?
    
    private var agentConnector: AIAgentConnector?

    init() {
        startSubscriptionPolling()

        guard let ai_model: String = CacheManager.shared.get(key: "models/current") else {return }
        guard let api_key: String = CacheManager.shared.get(key: "models/" + ai_model + "/api_key") else {return }
        setAgentSettings(model: ai_model, api_key: api_key)
    }

    deinit {
        subscriptionTask?.cancel()
    }

    func sendMessage(_ text: String, image: UIImage? = nil) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || image != nil else { return }

        if !isProUser && userMessageCount >= freeMessageLimit {
            showPaywall = true
            return
        }

        let imagePath = image.flatMap { saveImage($0) }
        let userMessage = Message(id: messages.count, content: text, isUser: true, imagePath: imagePath)
        messages.append(userMessage)
        
        if self.agentConnector != nil {
            self.isTyping = true
            self.agentConnector?.sendMessage(message: userMessage)
        }
    }

    func startCategoryChat(_ category: ChatCategory) {
        selectedCategory = category
        messages = []
        let aiMessage = Message(id: messages.count, content: category.initialMessage, isUser: false)
        messages.append(aiMessage)
    }

    func copyMessage(_ message: Message) {
        UIPasteboard.general.string = message.content
        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showCopiedToast = false
        }
    }

    func regenerateLastResponse() {
        guard let lastAIIndex = messages.lastIndex(where: { !$0.isUser }) else { return }
        messages.remove(at: lastAIIndex)
        
        guard messages.isEmpty == false else { return }
        if self.agentConnector != nil {
            self.isTyping = true
            self.agentConnector?.sendMessage(message: messages.last!)
        }
    }

    func setAgentSettings(model: String, api_key: String){
        if self.agentConnector != nil {
            self.agentConnector?.unsubscribe()
        }
        
        if (self.agentConnector == nil) || (self.agentConnector!.getModel() != model) {
            if model == "chat_gpt" {
                self.agentConnector = ChatGptConnector(api_key: api_key)
                self.agentConnector?.subscribeOnResponse(subscriber: {
                    (response: Message) in
                    
                    self.messages.append(response)
                    self.isTyping = false
                })
                print("model created: ChatGptConnector")
            } else {
                print("unknown model passed")
            }
        }
    }
    
    private func startSubscriptionPolling() {
        subscriptionTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.checkSubscriptionStatus()
                try? await Task.sleep(for: .seconds(10))
            }
        }
    }

    private func checkSubscriptionStatus() async {
        var hasActive = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.revocationDate == nil {
                hasActive = true
                break
            }
        }
        isProUser = hasActive
    }
    
    private func saveImage(_ image: UIImage) -> String? {
        guard let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
              let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileURL = cachesDir.appendingPathComponent(UUID().uuidString + ".jpg")
        try? data.write(to: fileURL)
        return fileURL.path
    }
}

class AIAgentConnector {
    var subscriber: ((Message)->Void)? = nil
    
    func unsubscribe(){
        subscriber = nil
    }
    func sendMessage(message: Message) {}
    func subscribeOnResponse(subscriber: @escaping (Message)->Void) {
        self.subscriber = subscriber
    }
    
    func getModel() -> String {
        return "not implemented"
    }
    
    func sendResponse(_ response: Message) {
        if self.subscriber == nil {
            return
            
        }
        
        DispatchQueue.main.async{
            self.subscriber!(response)
        }
    }
}

class ChatGptConnector: AIAgentConnector {
    private var api_key: String = ""
    
    init(api_key: String) {
        self.api_key = api_key
    }
    
    override func getModel() -> String {
        return "chat_gpt"
    }
    
    override func sendMessage(message: Message) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        let messages = [
            ["role": "system", "content": "You are a helpful assistant."],
            ["role": "user", "content": message.content]
        ]

        let json: [String: Any] = [
            "model": "gpt-5.4-mini",
            "messages": messages,
            "response_format": [
                                    "type": "text"
                                ]
        ]

        guard let json_data = try? JSONSerialization.data(withJSONObject: json) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(api_key)", forHTTPHeaderField: "Authorization")
        request.httpBody = json_data

        let fetchTask = Task {
            let taskResult = try await sendImpl(message: request)
            try Task.checkCancellation()
            return taskResult
        }
                
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: 3 * 1000000000)
            fetchTask.cancel()
        }
        Task {
            do {
                let result = try await fetchTask.value
                timeoutTask.cancel()
                sendResponse(Message(id: message.id + 1, content: result, isUser: false))
            } catch  let error {
                print("Error occured: ", error.localizedDescription)
                sendResponse(Message(id: message.id + 1, content: "Error occured: " + error.localizedDescription, isUser: false))
            }
        }
    }
    
    private func sendImpl(message: URLRequest) async throws -> String {
        let (response_data, _) = try await URLSession.shared.data(for: message)
        
        let decoder = JSONDecoder()
        let openAIResponse = try decoder.decode(OpenAIResponse.self, from: response_data)
        
        if (openAIResponse.error == nil) {
            if (openAIResponse.output != nil){
                let response_output = openAIResponse.output!
                let messageContent = response_output.first!.content.first!.text
                
                return messageContent
                
            }
            else {
                return "Model don't answering"
            }
        } else {
            return openAIResponse.error!.message
        }
    }
}


// MARK: - Response Models
struct OpenAIResponse: Codable {
let error: ErrorContent?
let output: [ChatResponce]?
}

struct ChatResponce: Codable {
let content: [ChatContent]
}

struct ChatContent: Codable {
let type: String
let text: String
let annotations: [String]
}

struct ErrorContent: Codable {
let type: String
let message: String
let code: String
}
