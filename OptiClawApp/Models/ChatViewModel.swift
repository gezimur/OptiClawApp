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

    init() {
        startSubscriptionPolling()
    }

    deinit {
        subscriptionTask?.cancel()
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

    func sendMessage(_ text: String, image: UIImage? = nil) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || image != nil else { return }

        if !isProUser && userMessageCount >= freeMessageLimit {
            showPaywall = true
            return
        }

        let imagePath = image.flatMap { saveImage($0) }
        let userMessage = Message(id: messages.count, content: text, isUser: true, imagePath: imagePath)
        messages.append(userMessage)
        simulateAIResponse()
    }

    private func saveImage(_ image: UIImage) -> String? {
        guard let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
              let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileURL = cachesDir.appendingPathComponent(UUID().uuidString + ".jpg")
        try? data.write(to: fileURL)
        return fileURL.path
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
        simulateAIResponse()
    }

    private func simulateAIResponse() {
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            self.isTyping = false
            let response = Message(
                id: self.messages.count,
                content: "Here are some of the best ways to invest money:\n\nStock Market: Investing in individual stocks or exchange-traded funds (ETFs) can offer significant growth potential, though it comes with higher risk.\n\nMutual Funds: These funds pool money from multiple investors to invest in a diversified portfolio of stocks, bonds, or other securities. They are managed by professionals.\n\nBonds: Investing in government or corporate bonds can provide steady income with lower risk compared to stocks, making them a more conservative investment option.",
                isUser: false
            )
            self.messages.append(response)
        }
    }
}

//class AIConnector {
//    private var api_url: String = ""
//    private var api_key: String = ""
//    
//    func askChat(message: String) -> Void {
//        guard let url = URL(string: api_url) else { return }
//
//        let messages = [
//            ["role": "system", "content": "You are a helpful assistant."],
//            ["role": "user", "content": message]
//        ]
//
//        let json: [String: Any] = [
//            "model": "gpt-4o-mini",
//            "messages": messages,
//            "response_format": [
//                                    "type": "text"
//                                ]
//        ]
//
//        guard let json_data = try? JSONSerialization.data(withJSONObject: json) else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(api_key)", forHTTPHeaderField: "Authorization")
//        request.httpBody = json_data
//
//        Task {
//            do {
//                let (response_data, _) = try await URLSession.shared.data(for: request)
//                
//                let decoder = JSONDecoder()
//                let openAIResponse = try decoder.decode(OpenAIResponse.self, from: response_data)
//                
//                if (openAIResponse.error == nil) {
//                    if (openAIResponse.output != nil){
//                        let response_output = openAIResponse.output!
//                        self.subscriber(response_output.first!.content.first!.text)
//                    }
//                } else {
//                    self.subscriber(openAIResponse.error!.message)
//                }
//                
//            } catch let error {
//                print("Error occured: ", error.localizedDescription)
//            }
//        }
//    }
//}
//
//
//
//// MARK: - Response Models
//struct OpenAIResponse: Codable {
//let error: ErrorContent?
//let output: [ChatResponce]?
//}
//
//struct ChatResponce: Codable {
//let content: [ChatContent]
//}
//
//struct ChatContent: Codable {
//let type: String
//let text: String
//let annotations: [String]
//}
//
//struct ErrorContent: Codable {
//let type: String
//let message: String
//let code: String
//}
