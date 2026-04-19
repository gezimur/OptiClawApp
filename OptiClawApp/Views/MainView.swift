import SwiftUI
import Foundation

enum AppNavigation {
    case chat, settings, history
    case back, appStartup
}

struct MainNavigationView: View {
    public var navigateTo: (AppNavigation) -> Void
    
    var body: some View {
        // Header
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("OptiClaw")
                    .font(AppTheme.medium(28))
                    .foregroundColor(.white)
                Text("Your AI Assistant")
                    .font(AppTheme.regular(15))
                    .foregroundColor(AppTheme.secondaryText)
            }
            Spacer()
            HStack(spacing: 16) {
                Button { navigateTo(.settings) } label: {
                    headerIconView("icon_settings")
                }
                Button { navigateTo(.history) } label: {
                    headerIconView("icon_clock")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private func headerIconView(_ name: String) -> some View {
            Image(name)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
                .frame(width: 54, height: 54)
                .background(AppTheme.cardBg)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.borderColor, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct MainView: View {
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var historyManager = ChatHistoryManager()
    
    @State private var location = AppNavigation.chat
    @State private var prevLocation = AppNavigation.appStartup
    
    var body: some View {
        ZStack {
            makeBackground()
            
            VStack {
                if location == AppNavigation.chat {
                    if viewModel.messages.isEmpty {
                        MainNavigationView(navigateTo: navigate)
                    } else {
                        ChatNavigationView(viewModel: viewModel, startNewChat: startNewChat)
                    }
                    
                    ChatView(viewModel: viewModel, startNewChat: startNewChat)
                    
                } else if location == AppNavigation.settings {
                    SettingsView(navigateTo: navigate, agentSettingsSubscriber: {
                        (model: String, api_key: String) in
                        viewModel.setAgentSettings(model: model, api_key: api_key)
                    })
                } else if location == AppNavigation.history {
                    HistoryView(historyManager: historyManager, navigateTo: navigate)
                } else { // by normal this code will never reached
                    Button(action: {navigate(dst: .chat)})
                    {
                        Text("Something went wrong")
                    }
                }
            }
            
            if location == .chat && viewModel.messages.isEmpty {
                makeGreatingsMascot()
            }
        //            .onTapGesture {
        //                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        //            }
        }
        .onChange(of: location) {
            if location == AppNavigation.chat {
                if historyManager.hasActiveSession() {
                    viewModel.messages = historyManager.getActiveSessionMessages()
                } else {
                    historyManager.updateActiveSession(messages: viewModel.messages)
                }
            } else {
                historyManager.updateActiveSession(messages: viewModel.messages)
                historyManager.closeActiveSession()
            }
        }
    }

    private func chip(_ cat: ChatCategory) -> some View {
        Button {
            viewModel.startCategoryChat(cat)
            location = AppNavigation.chat
        } label: {
            Text("\(cat.emoji) \(cat.rawValue)")
                .font(AppTheme.regular(15))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.cardBg)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.borderColor, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func makeBackground() -> some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            // Top red glow (original working gradient)
            VStack {
                EllipticalGradient(
                    colors: [
                        AppTheme.topGlow.opacity(0.45),
                        AppTheme.topGlow.opacity(0.15),
                        Color.clear
                    ],
                    center: .top,
                    startRadiusFraction: 0.0,
                    endRadiusFraction: 0.7
                )
                .frame(height: 300)
                .ignoresSafeArea(edges: .top)
                Spacer()
            }
        }
    }
    
    private func makeGreatingsMascot() -> some View{
        VStack(spacing: 0) {
            Spacer()

            // Mascot
            Image("mascot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)

            // Title
            Text("Hi there!")
                .font(AppTheme.medium(24))
                .foregroundColor(.white)
                .padding(.top, 8)

            Text("Type a question or pick one of these:")
                .font(AppTheme.regular(15))
                .foregroundColor(AppTheme.secondaryText)
                .padding(.top, 2)

            // Chips
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    chip(.checkGrammar)
                    chip(.socialMedia)
                }
                HStack(spacing: 12) {
                    chip(.travel)
                    chip(.essay)
                    chip(.cooking)
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    
    private func navigate(dst: AppNavigation){
        if dst == AppNavigation.back {
            if prevLocation == AppNavigation.appStartup {
                location = AppNavigation.chat
            } else {
                location = prevLocation
            }
            
            prevLocation = AppNavigation.appStartup
        } else {
            prevLocation = location
            location = dst
        }
    }
    
    private func startNewChat() {
        historyManager.updateActiveSession(messages: viewModel.messages)
        historyManager.closeActiveSession()
        
        viewModel.messages = historyManager.getActiveSessionMessages()
        viewModel.selectedCategory = nil
        viewModel.showNewChatSheet = false
    }
}

#Preview {
    MainView()
}
