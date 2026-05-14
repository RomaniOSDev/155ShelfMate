import SwiftUI

struct QuoteCard: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundColor(.shelfRead)

                Text(quote.bookTitle)
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                if quote.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.shelfRead)
                        .font(.caption)
                }
            }

            Text(quote.text)
                .font(.body)
                .foregroundColor(.shelfProgress)
                .italic()

            if let page = quote.page {
                Text("Page \(page)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .shelfCardStyle(radius: 14)
    }
}
