import SwiftUI
import StoreKit

struct SettingsView: View {
    enum SettingsPages {
        case base, ai_agent
    }
    
    @Environment(\.requestReview) private var requestReview
    @State private var currentPage = SettingsPages.base
    @State private var api_key: String = ""
    
    var navigateTo: (AppNavigation) -> Void
    var agentSettingsSubscriber: (String, String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                makeNavigationView()
                
                if currentPage == .base {
                    makeBaseSettingsView()
                } else if currentPage == .ai_agent {
                    makeAiSettingsView()
                }
                
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .background(.gray.opacity(0.0))
    }

    private func makeBaseSettingsView() -> some View {
        VStack {
            settingsRow(emoji: ":)", title: "AI Agent", action: {
                currentPage = .ai_agent
            })
            
            settingsRow(emoji: "⭐️", title: "Rate Us") {
                requestReview()
            }

            settingsRow(emoji: "🔗", title: "Share App") {
                shareApp()
            }

            settingsRow(emoji: "💌", title: "Contact Us") {
                if let url = URL(string: "mailto:support@opticlaw.app") {
                    UIApplication.shared.open(url)
                }
            }

            settingsRow(emoji: "🔒", title: "Privacy Policy") {
                if let url = URL(string: "https://opticlaw.app/privacy") {
                    UIApplication.shared.open(url)
                }
            }

            settingsRow(emoji: "📄", title: "Terms of Use") {
                if let url = URL(string: "https://opticlaw.app/terms") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    private func makeAiSettingsView() -> some View {
        VStack {
            
            TextField("", text: $api_key, prompt: Text("Copy your key here").foregroundColor(AppTheme.placeholderText), axis: .vertical)
                .font(AppTheme.regular(15))
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.borderColor, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer()
            
            Button(action: {
                CacheManager.shared.set(key: "models/current", value: "chat_gpt")
                CacheManager.shared.set(key: "models/chat_gpt/api_key", value: api_key)
                
                agentSettingsSubscriber("chat_gpt", api_key)
                
            }) {
                HStack {
                    Text("Confirm")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppTheme.cardBg)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.borderColor, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    private func makeNavigationView() -> some View{
        HStack {
            Button(action: {
                if currentPage == .base{
                    navigateTo(.back)
                } else {
                    currentPage = .base
                }
                
            }) {
                Image("icon_arrow_back")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.cardBg)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.borderColor, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Spacer()

            if currentPage == .base {
                Text("Settings")
                    .font(AppTheme.medium(18))
                    .foregroundColor(.white)
            } else if currentPage == .ai_agent {
                Text("AI Agent")
                    .font(AppTheme.medium(18))
                    .foregroundColor(.white)
            }

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    private func settingsRow(emoji: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 22))
                    .frame(width: 36, height: 36)

                Text(title)
                    .font(AppTheme.medium(16))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.cardBg)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.borderColor, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func shareApp() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        let items: [Any] = ["Check out OptiClaw - Your AI Assistant!", URL(string: "https://apps.apple.com/app/opticlaw") as Any]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        window.rootViewController?.present(vc, animated: true)
    }
}
