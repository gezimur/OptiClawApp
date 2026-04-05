import SwiftUI

// MARK: - Popup background style (Figma: backdrop-blur + AE1229 dark tinted)
private struct PopupBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(AppTheme.background.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(red: 174/255, green: 18/255, blue: 41/255).opacity(0.12))
                    )
                    .blur(radius: 0.5)
            )
            .overlay(RoundedRectangle(cornerRadius: 30).stroke(AppTheme.borderColor, lineWidth: 1.5))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal, 20)
    }
}

// MARK: - New Chat Sheet
struct NewChatSheetView: View {
    let onStartNew: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("New chat?")
                    .font(AppTheme.medium(24))
                    .foregroundColor(.white)

                Text("Don't worry, your current\nconversation will be kept in history")
                    .font(AppTheme.light(14))
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                Button(action: onStartNew) {
                    Text("Start new chat")
                        .font(AppTheme.medium(16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(AppTheme.ctaGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                Button(action: onCancel) {
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
        .padding(.top, 18)
        .padding(.bottom, 14)
        .modifier(PopupBackground())
    }
}

// MARK: - Attachment Sheet
struct AttachmentSheetView: View {
    let onPickFromLibrary: () -> Void
    let onSnapPicture: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Select an option")
                .font(AppTheme.medium(24))
                .foregroundColor(.white)

            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    attachRow("icon_photo", "Pick from Library", onPickFromLibrary)
                    attachRow("icon_camera", "Snap a Picture", onSnapPicture)
                }

                Button(action: onCancel) {
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
        .modifier(PopupBackground())
    }

    private func attachRow(_ icon: String, _ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(AppTheme.ctaGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(title)
                    .font(AppTheme.medium(16))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 5)
            .frame(height: 58)
            .background(AppTheme.cardBg)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.borderColor, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

// MARK: - Copied Toast
struct CopiedToastView: View {
    var body: some View {
        Text("Copied")
            .font(AppTheme.medium(14))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }
}

// MARK: - Error Banner
struct ErrorBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi.slash").font(.system(size: 12))
            Text(message).font(AppTheme.medium(13))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppTheme.ctaGradient)
        .clipShape(Capsule())
    }
}
