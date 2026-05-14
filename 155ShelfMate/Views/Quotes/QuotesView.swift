import SwiftUI

struct QuotesView: View {
    @ObservedObject var viewModel: ShelfMateViewModel

    @State private var showAddQuoteSheet = false
    @State private var selectedBookId: UUID?
    @State private var quoteText = ""
    @State private var quotePage: Int?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.quotes) { quote in
                        QuoteCard(quote: quote)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteQuote(quote)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    viewModel.toggleFavoriteQuote(quote)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                            }
                    }

                    Button("Add Quote") {
                        selectedBookId = viewModel.books.first?.id
                        quoteText = ""
                        quotePage = nil
                        showAddQuoteSheet = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .shelfAccentButtonStyle(radius: 12)
                }
                .padding()
            }
            .background(Color.shelfBackground.ignoresSafeArea())
            .navigationTitle("Favorite Quotes")
            .sheet(isPresented: $showAddQuoteSheet) {
                NavigationStack {
                    Form {
                        Picker("Book", selection: $selectedBookId) {
                            ForEach(viewModel.books) { book in
                                Text(book.title).tag(book.id as UUID?)
                            }
                        }

                        TextEditor(text: $quoteText)
                            .frame(height: 120)

                        HStack {
                            Text("Page")
                            Spacer()
                            TextField("", value: $quotePage, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .navigationTitle("New Quote")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showAddQuoteSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                guard
                                    let bookId = selectedBookId,
                                    let book = viewModel.books.first(where: { $0.id == bookId }),
                                    !quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                else { return }

                                let quote = Quote(
                                    id: UUID(),
                                    bookId: bookId,
                                    bookTitle: book.title,
                                    text: quoteText.trimmingCharacters(in: .whitespacesAndNewlines),
                                    page: quotePage,
                                    isFavorite: false,
                                    createdAt: Date()
                                )
                                viewModel.addQuote(quote)
                                showAddQuoteSheet = false
                            }
                        }
                    }
                }
            }
        }
    }
}
