import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager: ChatHistoryManager
    @Environment(\.dismiss) private var dismiss
    @State private var showClearConfirm = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            // Top glow
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

            VStack(spacing: 0) {
                // Nav bar
                HStack {
                    Button(action: { dismiss() }) {
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

                    Button(action: { showClearConfirm = true }) {
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
                            NavigationLink(value: session.id) {
                                HStack(spacing: 12) {
                                    Image("mascot")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))

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
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }

            // Clear all confirmation
            if showClearConfirm {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { showClearConfirm = false }

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
                                showClearConfirm = false
                            } label: {
                                Text("Clear all")
                                    .font(AppTheme.medium(16))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(AppTheme.ctaGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }

                            Button { showClearConfirm = false } label: {
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
        .animation(.easeInOut(duration: 0.3), value: showClearConfirm)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
