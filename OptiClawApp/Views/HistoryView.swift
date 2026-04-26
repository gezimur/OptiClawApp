import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager: ChatHistoryManager
    
    let navigateTo: (AppNavigation) -> Void

    @State private var renamingSessionID: Int? = nil
    @State private var renameText = ""

    var body: some View {
        ZStack {
            VStack {
                makeNavigationView()

                if historyManager.sessions.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Text("🕐")
                            .font(.system(size: 48))
                        Text("No chats yet")
                            .font(AppTheme.regular(16))
                            .foregroundColor(AppTheme.secondaryText)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(historyManager.sessions) { session in
                            Button(action: {
                                historyManager.makeSessionActive(id: session.id)
                                navigateTo(.chat)
                            }){
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.title)
                                            .font(AppTheme.medium(15))
                                            .foregroundColor(.white)
                                            .lineLimit(1)

                                        Text(session.preview)
                                            .font(AppTheme.regular(13))
                                            .foregroundColor(AppTheme.secondaryText)
                                            .lineLimit(2)
                                    }

                                    Spacer()

                                    Text(session.formattedDate)
                                        .font(AppTheme.regular(12))
                                        .foregroundColor(AppTheme.secondaryText)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(AppTheme.cardBg)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.borderColor, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .id(session.id)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    historyManager.deleteSession(session)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    renameText = session.title
                                    renamingSessionID = session.id
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }

            // Clear all confirmation
            if historyManager.showClearConfirm {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { historyManager.showClearConfirm = false }

                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Clear history?")
                                .font(AppTheme.medium(24))
                                .foregroundColor(.white)
                            Text("This will delete all your chat history")
                                .font(AppTheme.light(14))
                                .foregroundColor(AppTheme.secondaryText)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: 10) {
                            Button {
                                historyManager.clearAll()
                                historyManager.showClearConfirm = false
                            } label: {
                                Text("Clear all")
                                    .font(AppTheme.medium(16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(AppTheme.ctaGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }

                            Button { historyManager.showClearConfirm = false } label: {
                                Text("Cancel")
                                    .font(AppTheme.medium(16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(AppTheme.cardBg)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.borderColor, lineWidth: 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 22)
                    .padding(.bottom, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(AppTheme.background.opacity(0.85))
                            .overlay(RoundedRectangle(cornerRadius: 30).fill(Color(red: 174/255, green: 18/255, blue: 41/255).opacity(0.12)))
                    )
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(AppTheme.borderColor, lineWidth: 1.5))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            // Rename popup
            if renamingSessionID != nil {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { renamingSessionID = nil }

                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Rename chat")
                                .font(AppTheme.medium(24))
                                .foregroundColor(.white)
                            Text("Enter a new name for this conversation")
                                .font(AppTheme.light(14))
                                .foregroundColor(AppTheme.secondaryText)
                                .multilineTextAlignment(.center)
                        }

                        TextField("", text: $renameText, prompt: Text("Chat name...").foregroundColor(AppTheme.placeholderText))
                            .font(AppTheme.regular(15))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            .background(AppTheme.cardBg)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.borderColor, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        VStack(spacing: 10) {
                            Button {
                                if let id = renamingSessionID {
                                    historyManager.renameSession(id: id, newTitle: renameText)
                                }
                                renamingSessionID = nil
                            } label: {
                                Text("Save")
                                    .font(AppTheme.medium(16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(AppTheme.ctaGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }

                            Button { renamingSessionID = nil } label: {
                                Text("Cancel")
                                    .font(AppTheme.medium(16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(AppTheme.cardBg)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.borderColor, lineWidth: 1))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 22)
                    .padding(.bottom, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(AppTheme.background.opacity(0.85))
                            .overlay(RoundedRectangle(cornerRadius: 30).fill(Color(red: 174/255, green: 18/255, blue: 41/255).opacity(0.12)))
                    )
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(AppTheme.borderColor, lineWidth: 1.5))
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: historyManager.showClearConfirm)
        .animation(.easeInOut(duration: 0.3), value: renamingSessionID)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func makeNavigationView() -> some View{
        HStack {
            Button(action: { navigateTo(.back) }) {
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

            Text("History")
                .font(AppTheme.medium(18))
                .foregroundColor(.white)

            Spacer()

            Button(action: { historyManager.showClearConfirm = true }) {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(historyManager.sessions.isEmpty ? 0.3 : 1))
                    .frame(width: 44, height: 44)
                    .background(AppTheme.cardBg)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.borderColor, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(historyManager.sessions.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(.gray.opacity(0.0))
    }
}
