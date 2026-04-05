import SwiftUI

struct TypingIndicatorView: View {
    @State private var phase = 0

    private let shape = UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16, topTrailingRadius: 16)

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Image("mascot")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.borderColor, lineWidth: 1))

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 7, height: 7)
                        .offset(y: phase == i ? -3 : 0)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.cardBg)
            .overlay(shape.stroke(AppTheme.borderColor, lineWidth: 1))
            .clipShape(shape)

            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.25)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}
