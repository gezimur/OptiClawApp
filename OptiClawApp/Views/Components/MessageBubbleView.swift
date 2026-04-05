import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let onCopy: () -> Void
    let onShare: () -> Void
    let onRegenerate: () -> Void
    let isLastAI: Bool

    private let aiShape = UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16, topTrailingRadius: 16)
    private let userShape = UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 16, bottomTrailingRadius: 4, topTrailingRadius: 16)

    var body: some View {
        if message.isUser {
            userBubble
        } else {
            aiBubble
        }
    }

    private var userBubble: some View {
        HStack {
            Spacer(minLength: 60)
            VStack(alignment: .trailing, spacing: 8) {
                if let img = message.image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 200, maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                if !message.content.isEmpty {
                    Text(message.content)
                        .font(AppTheme.regular(15))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(AppTheme.userBubble)
                        .clipShape(userShape)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var aiBubble: some View {
        HStack(alignment: .bottom, spacing: 8) {
            botAvatar

            VStack(alignment: .leading, spacing: 0) {
                // Message text + action buttons inside one container
                VStack(alignment: .leading, spacing: 16) {
                    Text(message.content)
                        .font(AppTheme.regular(15))
                        .foregroundColor(.white)

                    if isLastAI {
                        HStack(spacing: 5) {
                            actionBtn("icon_copy", "Copy", onCopy)
                            actionBtn("icon_share", "Share", onShare)
                            actionBtn("icon_regenerate", "Regenerate", onRegenerate)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardBg)
                .overlay(aiShape.stroke(AppTheme.borderColor, lineWidth: 1))
                .clipShape(aiShape)
            }

            Spacer(minLength: 0)
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

    private func actionBtn(_ iconName: String, _ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(iconName)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                Text(title)
                    .font(AppTheme.regular(12))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(AppTheme.actionBtnBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
