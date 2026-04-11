import Foundation
import SwiftUI

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

    var isProUser = false
    private let freeMessageLimit = 3
    var userMessageCount: Int { messages.filter(\.isUser).count }

    func sendMessage(_ text: String, image: UIImage? = nil) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || image != nil else { return }

        if !isProUser && userMessageCount >= freeMessageLimit {
            showPaywall = true
            return
        }

        let userMessage = Message(content: text, isUser: true, image: image)
        messages.append(userMessage)
        simulateAIResponse()
    }

    func startCategoryChat(_ category: ChatCategory) {
        selectedCategory = category
        messages = []
        let aiMessage = Message(content: category.initialMessage, isUser: false)
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
                content: "Here are some of the best ways to invest money:\n\nStock Market: Investing in individual stocks or exchange-traded funds (ETFs) can offer significant growth potential, though it comes with higher risk.\n\nMutual Funds: These funds pool money from multiple investors to invest in a diversified portfolio of stocks, bonds, or other securities. They are managed by professionals.\n\nBonds: Investing in government or corporate bonds can provide steady income with lower risk compared to stocks, making them a more conservative investment option.",
                isUser: false
            )
            self.messages.append(response)
        }
    }
}
