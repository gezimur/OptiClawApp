import SwiftUI
import UIKit

enum AppTheme {
    // MARK: - Colors (Figma exact)
    static let background = Color(red: 0.016, green: 0.016, blue: 0.02) // #040405
    static let cardBg = Color(red: 174/255, green: 18/255, blue: 41/255).opacity(0.16)
    static let borderColor = Color.white.opacity(0.2)
    static let borderColorPopup = Color.white.opacity(0.2)
    static let userBubble = Color(red: 174/255, green: 18/255, blue: 41/255).opacity(0.45)
    static let secondaryText = Color(red: 0x71/255, green: 0x71/255, blue: 0x7F/255) // #71717F
    static let placeholderText = Color.white.opacity(0.4)
    static let plusBtnBg = Color.white.opacity(0.12)
    static let sendBtnBg = Color.white.opacity(0.12)
    static let actionBtnBg = Color.white.opacity(0.12)
    static let overlayBg = Color.black.opacity(0.6)
    static let handleBar = Color.white.opacity(0.05)

    // Gradient for red glow at top (AE1229)
    static let topGlow = Color(red: 174/255, green: 18/255, blue: 41/255)

    // CTA gradient
    static let gradientStart = Color(red: 0xE1/255, green: 0x11/255, blue: 0x31/255) // #E11131
    static let gradientEnd = Color(red: 0xAE/255, green: 0x12/255, blue: 0x29/255) // #AE1229

    static var ctaGradient: LinearGradient {
        LinearGradient(colors: [gradientStart, gradientEnd], startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Fonts (Poppins with system fallback)
    static func medium(_ size: CGFloat) -> Font {
        if UIFont(name: "Poppins-Medium", size: size) != nil {
            return .custom("Poppins-Medium", size: size)
        }
        return .system(size: size, weight: .medium)
    }

    static func regular(_ size: CGFloat) -> Font {
        if UIFont(name: "Poppins-Regular", size: size) != nil {
            return .custom("Poppins-Regular", size: size)
        }
        return .system(size: size, weight: .regular)
    }

    static func light(_ size: CGFloat) -> Font {
        if UIFont(name: "Poppins-Light", size: size) != nil {
            return .custom("Poppins-Light", size: size)
        }
        return .system(size: size, weight: .light)
    }

    static func semiBold(_ size: CGFloat) -> Font {
        if UIFont(name: "Poppins-SemiBold", size: size) != nil {
            return .custom("Poppins-SemiBold", size: size)
        }
        return .system(size: size, weight: .semibold)
    }
}
