import SwiftUI

struct BookCard: View {
    let book: Book
    let color: Color
    
    private var checksum: Int {
        book.id.uuidString.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    }
    
    private var cardHeight: CGFloat {
        CGFloat(166 + (checksum % 20))
    }
    
    private var tiltAngle: Double {
        Double((checksum % 7) - 3) * 0.7
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 130, height: cardHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 4)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.opacity(0.22))
                            .frame(width: 10)
                    }

                RoundedRectangle(cornerRadius: 9)
                    .fill(color.opacity(0.11))
                    .frame(width: 104, height: 136)
                    .overlay {
                        Image(systemName: book.genre.icon)
                            .font(.system(size: 30))
                            .foregroundColor(color)
                    }
                    .padding(.top, 20)

                if book.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.shelfRead)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding(8)
                }
            }
            .rotationEffect(.degrees(tiltAngle), anchor: .bottom)
            .offset(y: (186 - cardHeight))

            Text(book.title)
                .font(.headline)
                .foregroundColor(.shelfProgress)
                .lineLimit(1)
                .frame(width: 130, alignment: .leading)

            Text(book.author)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(width: 130, alignment: .leading)

            if book.status == .reading, let current = book.currentPage {
                Text("\(current)/\(book.totalPages) pages")
                    .font(.caption2)
                    .foregroundColor(color)

                ProgressView(value: book.progress)
                    .tint(color)
                    .frame(width: 130)
            } else if book.status == .read, let rating = book.rating {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(.shelfRead)
                    }
                }
            }
        }
        .frame(width: 130)
        .animation(.easeOut(duration: 0.25), value: book.currentPage)
    }
}
