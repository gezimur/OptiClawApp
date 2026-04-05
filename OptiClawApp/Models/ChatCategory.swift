import Foundation

enum ChatCategory: String, CaseIterable, Identifiable {
    case checkGrammar = "Check grammar"
    case socialMedia = "Sosial media"
    case travel = "Travel"
    case essay = "Essay"
    case cooking = "Cooking"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .checkGrammar: return "\u{270D}\u{1F3FB}"
        case .socialMedia: return "\u{1F4AC}"
        case .travel: return "\u{1F6EB}"
        case .essay: return "\u{1F4DD}"
        case .cooking: return "\u{1F9D1}\u{200D}\u{1F373}"
        }
    }

    var initialMessage: String {
        switch self {
        case .checkGrammar:
            return "Paste your text here and I'll check the grammar, spelling, and clarity. I can also help rewrite it to sound more natural."
        case .socialMedia:
            return "Tell me what platform you're posting on and what your post is about. I can help you write captions, hashtags, or content ideas."
        case .travel:
            return "Where are you planning to travel? I can help with itineraries, tips, places to visit, and travel planning."
        case .essay:
            return "Tell me your topic or paste your draft. I can help you brainstorm ideas, structure your essay, or improve your writing."
        case .cooking:
            return "What would you like to cook? Tell me the ingredients you have or the dish you're interested in, and I'll help with a recipe."
        }
    }
}
