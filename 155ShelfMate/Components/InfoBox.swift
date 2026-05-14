import SwiftUI

struct InfoBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)

            Text(value)
                .font(.caption)
                .foregroundColor(.shelfProgress)
                .multilineTextAlignment(.center)

            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .shelfCardStyle(radius: 14)
    }
}
