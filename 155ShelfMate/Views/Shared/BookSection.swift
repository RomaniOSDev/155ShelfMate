import SwiftUI

struct BookSection: View {
    let title: String
    let books: [Book]
    let color: Color
    let onSelect: (Book) -> Void
    let onDelete: (Book) -> Void
    let onFavorite: (Book) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
                Text("\(books.count)")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.12))
                    .foregroundColor(color)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(books) { book in
                        BookCard(book: book, color: color)
                            .onTapGesture { onSelect(book) }
                            .contextMenu {
                                Button(role: .destructive) {
                                    onDelete(book)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    onFavorite(book)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            Rectangle()
                .fill(color.opacity(0.2))
                .frame(height: 8)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(color.opacity(0.35))
                        .frame(height: 2)
                }
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .cornerRadius(4)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}
