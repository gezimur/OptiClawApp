import SwiftUI
import Combine
import PhotosUI

struct ChatNavigationView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var startNewChat: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { startNewChat() }) {
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
                Text("OptiClaw")
                    .font(AppTheme.medium(18))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { viewModel.showNewChatSheet = true }) {
                    Image("icon_new_chat")
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
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            if let error = viewModel.networkError {
                ErrorBannerView(message: error).padding(.top, 4)
            }
        }
        
    }
}

// TODO: Add blur to background
// TODO: fix overlay background (make invisible)

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    
    @State private var showImagePicker = false
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var pendingImage: UIImage?

    let startNewChat: () -> Void
    
    private var keyboardWillShow: AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .eraseToAnyPublisher()
    }

    private var keyboardWillHide: AnyPublisher<Notification, Never> {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .eraseToAnyPublisher()
    }

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {

                // Chat scroll
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            LazyVStack(spacing: 16) {
//                                if viewModel.messages.isEmpty {
//                                    aiBubble("Hi! I'm OptiClaw. How can I help you today?")
//                                }
                                ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { idx, msg in
                                    MessageBubbleView(
                                        message: msg,
                                        onCopy: { viewModel.copyMessage(msg) },
                                        onShare: { shareMessage(msg) },
                                        onRegenerate: { viewModel.regenerateLastResponse() },
                                        isLastAI: idx == viewModel.messages.count - 1 && !msg.isUser
                                    )
                                    .id(msg.id)
                                }
                                if viewModel.isTyping {
                                    TypingIndicatorView().id("typing")
                                }
                                Color.clear.frame(height: 1).id("bottom")
                            }
                            .padding(.vertical, 16)
                        }
                        .frame(minHeight: UIScreen.main.bounds.height * 0.5)
                    }
                    .defaultScrollAnchor(.bottom)
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .scrollClipDisabled()
                    .mask(scrollEdgeFadeMask)
                    .onTapGesture { isInputFocused = false }
                    .onReceive(keyboardWillShow) { _ in
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onReceive(keyboardWillHide) { _ in
                        proxy.scrollTo("bottom", anchor: .bottom)
                        for delay in stride(from: 0.05, through: 0.4, by: 0.05) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: viewModel.messages.count) {
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                    .onChange(of: viewModel.isTyping) {
                        if viewModel.isTyping {
                            withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                        }
                    }
                    .onChange(of: inputText) {
                        if isInputFocused {
                            withAnimation(.easeOut(duration: 0.15)) {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                }

                // Pending image preview
                if let img = pendingImage {
                    HStack(spacing: 8) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.borderColor, lineWidth: 1))
                        Button {
                            pendingImage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 4)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // Input bar
                inputBar
            }

            // Copied toast
            if viewModel.showCopiedToast {
                VStack {
                    CopiedToastView().padding(.top, 60)
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.showCopiedToast)
            }

            // New Chat popup
            if viewModel.showNewChatSheet {
                Color.black.opacity(0.6).ignoresSafeArea()
                    .onTapGesture { viewModel.showNewChatSheet = false }
                VStack {
                    Spacer()
                    NewChatSheetView(
                        onStartNew: {
                            startNewChat()
                            viewModel.messages.append(Message(id: viewModel.messages.count, content: "Hi! I'm OptiClaw. How can I help you today?", isUser: false))
                        },
                        onCancel: { viewModel.showNewChatSheet = false }
                    ).padding(.bottom, 10)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Paywall
            if viewModel.showPaywall {
                Color.black.opacity(0.6).ignoresSafeArea()
                    .onTapGesture { viewModel.showPaywall = false }
                VStack {
                    Spacer()
                    PaywallView(
                        onUpgrade: {
                            viewModel.isProUser = true
                            viewModel.showPaywall = false
                        },
                        onDismiss: { viewModel.showPaywall = false }
                    ).padding(.bottom, 10)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Attachment popup
            if viewModel.showAttachmentSheet {
                Color.black.opacity(0.6).ignoresSafeArea()
                    .onTapGesture { viewModel.showAttachmentSheet = false }
                VStack {
                    Spacer()
                    AttachmentSheetView(
                        onPickFromLibrary: {
                            viewModel.showAttachmentSheet = false
                            showImagePicker = true
                        },
                        onSnapPicture: { viewModel.showAttachmentSheet = false },
                        onCancel: { viewModel.showAttachmentSheet = false }
                    ).padding(.bottom, 10)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showNewChatSheet)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showAttachmentSheet)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showPaywall)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .photosPicker(isPresented: $showImagePicker, selection: $selectedImageItem, matching: .images)
        .onChange(of: selectedImageItem) {
            guard let item = selectedImageItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run { pendingImage = image }
                }
                await MainActor.run { selectedImageItem = nil }
            }
        }
        .background(.gray.opacity(0.0))
    }

    // MARK: - Scroll Edge Fade Mask
    /// A vertical gradient mask applied directly to the ScrollView.
    /// White = fully visible, Clear = fully transparent.
    /// The fade regions (40pt each) only affect the scroll content area;
    /// the nav bar and input bar sit outside the ScrollView and are unaffected.
    private var scrollEdgeFadeMask: some View {
        VStack(spacing: 0) {
            // Top fade: clear → white over 40pt
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)

            // Middle: fully visible
            Rectangle().fill(Color.white)

            // Bottom fade: white → clear over 40pt
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
        }
    }

    // MARK: - AI Bubble
    private func aiBubble(_ text: String) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            botAvatar
            Text(text)
                .font(AppTheme.regular(15))
                .foregroundColor(.white)
                .padding(16)
                .background(AppTheme.cardBg)
                .overlay(
                    UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16, topTrailingRadius: 16)
                        .stroke(AppTheme.borderColor, lineWidth: 1)
                )
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16, topTrailingRadius: 16))
            Spacer(minLength: 20)
        }
        .padding(.horizontal, 20)
    }

    private var botAvatar: some View {
        Image("mascot")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 30, height: 30)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.borderColor, lineWidth: 1))
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        VStack(spacing: inputText.isEmpty ? 0 : 10) {
            HStack(alignment: inputText.isEmpty ? .center : .top, spacing: 10) {
                if inputText.isEmpty { plusButton }
                TextField("", text: $inputText, prompt: Text("Type here...").foregroundColor(AppTheme.placeholderText), axis: .vertical)
                    .font(AppTheme.regular(15))
                    .foregroundColor(.white)
                    .lineLimit(1...6)
                    .focused($isInputFocused)
                if inputText.isEmpty {
                    sendButton
                } else {
                    Button { inputText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            if !inputText.isEmpty {
                HStack {
                    plusButton
                    Spacer()
                    sendButton
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

    private var plusButton: some View {
        Button(action: { viewModel.showAttachmentSheet = true }) {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 30, height: 30)
                .background(AppTheme.plusBtnBg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var sendButton: some View {
        Button {
            guard !inputText.isEmpty || pendingImage != nil else { return }
            viewModel.sendMessage(inputText, image: pendingImage)
            inputText = ""
            pendingImage = nil
        } label: {
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity((inputText.isEmpty && pendingImage == nil) ? 0.4 : 1))
                .frame(width: 38, height: 38)
                .background((inputText.isEmpty && pendingImage == nil) ? AnyShapeStyle(AppTheme.sendBtnBg) : AnyShapeStyle(AppTheme.ctaGradient))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func shareMessage(_ message: Message) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        let vc = UIActivityViewController(activityItems: [message.content], applicationActivities: nil)
        window.rootViewController?.present(vc, animated: true)
    }
}
