import SwiftUI

extension LinearGradient {
    static let shelfAccent = LinearGradient(
        colors: [.shelfRead, .shelfProgress],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension View {
    func shelfCardStyle(radius: CGFloat = 16) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color.shelfBackground.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: Color.shelfProgress.opacity(0.08), radius: 12, x: 0, y: 7)
            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
    }

    func shelfAccentButtonStyle(radius: CGFloat = 12) -> some View {
        self
            .foregroundColor(.white)
            .background(LinearGradient.shelfAccent)
            .cornerRadius(radius)
            .shadow(color: Color.shelfProgress.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}
