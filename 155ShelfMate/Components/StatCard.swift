import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Text(value)
                .foregroundColor(.shelfProgress)
                .font(.title2)
                .bold()
        }
        .padding()
        .frame(width: 150, alignment: .leading)
        .shelfCardStyle(radius: 14)
    }
}
