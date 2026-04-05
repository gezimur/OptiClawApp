import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ChatViewModel()
    @StateObject private var historyManager = ChatHistoryManager()
    @State private var navigateToChat = false
    @State private var navigateToSettings = false
    @State private var navigateToHistory = false
    @State private var inputText = ""

    var body: some View {
        NavigationStack {
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

                VStack(spacing: 0) {
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
                            Button { navigateToSettings = true } label: {
                                headerIconView("icon_settings")
                            }
                            Button { navigateToHistory = true } label: {
                                headerIconView("icon_clock")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

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

                    // Input
                    inputBar
                }
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onChange(of: navigateToChat) {
                if navigateToChat {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            .navigationDestination(isPresented: $navigateToChat) {
                ChatView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
            .navigationDestination(isPresented: $navigateToHistory) {
                HistoryView(historyManager: historyManager)
            }
            .overlay {
                if viewModel.showAttachmentSheet {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                            .onTapGesture { viewModel.showAttachmentSheet = false }

                        VStack {
                            Spacer()
                            AttachmentSheetView(
                                onPickFromLibrary: { viewModel.showAttachmentSheet = false },
                                onSnapPicture: { viewModel.showAttachmentSheet = false },
                                onCancel: { viewModel.showAttachmentSheet = false }
                            )
                            .padding(.bottom, 10)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showAttachmentSheet)
                }
            }
        }
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

    private func chip(_ cat: ChatCategory) -> some View {
        Button {
            viewModel.startCategoryChat(cat)
            navigateToChat = true
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

    private var inputBar: some View {
        VStack(spacing: inputText.isEmpty ? 0 : 10) {
            HStack(alignment: inputText.isEmpty ? .center : .top, spacing: 10) {
                if inputText.isEmpty {
                    homePlusButton
                }

                TextField("", text: $inputText, prompt: Text("Type here...").foregroundColor(AppTheme.placeholderText), axis: .vertical)
                    .font(AppTheme.regular(15))
                    .foregroundColor(.white)
                    .lineLimit(1...6)

                if inputText.isEmpty {
                    homeSendButton
                } else {
                    Button {
                        inputText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }

            if !inputText.isEmpty {
                HStack {
                    homePlusButton
                    Spacer()
                    homeSendButton
                }
            }
        }
        .padding(inputText.isEmpty ? 6 : 8)
        .padding(.leading, inputText.isEmpty ? 6 : 0)
        .background(AppTheme.cardBg)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.borderColor, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
        .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)
    }

    private var homePlusButton: some View {
        Button(action: { viewModel.showAttachmentSheet = true }) {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 30, height: 30)
                .background(AppTheme.plusBtnBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var homeSendButton: some View {
        Button {
            guard !inputText.isEmpty else { return }
            viewModel.sendMessage(inputText)
            inputText = ""
            navigateToChat = true
        } label: {
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(inputText.isEmpty ? 0.4 : 1))
                .frame(width: 38, height: 38)
                .background(inputText.isEmpty ? AnyShapeStyle(AppTheme.sendBtnBg) : AnyShapeStyle(AppTheme.ctaGradient))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview {
    HomeView()
}
