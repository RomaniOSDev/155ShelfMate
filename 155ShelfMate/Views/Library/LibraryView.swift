import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: ShelfMateViewModel

    @State private var selectedBook: Book?
    @State private var showAddBookSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    heroHeader

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            StatCard(title: "Total Books", value: "\(viewModel.totalBooks)", icon: "books.vertical.fill", color: .shelfProgress)
                            StatCard(title: "Read", value: "\(viewModel.readBooksCount)", icon: "checkmark.circle.fill", color: .shelfRead)
                            StatCard(title: "Reading", value: "\(viewModel.readingBooksCount)", icon: "book.fill", color: .shelfProgress)
                            StatCard(title: "Pages", value: "\(viewModel.totalPagesRead)", icon: "doc.text.fill", color: .shelfRead)
                        }
                        .padding(.horizontal)
                    }

                    if let goal = viewModel.currentGoal {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Reading Mission")
                                    .font(.headline)
                                    .foregroundColor(.shelfProgress)

                                Spacer()

                                Text("\(goal.currentBooks)/\(goal.targetBooks) books")
                                    .foregroundColor(goal.isCompleted ? .shelfRead : .shelfProgress)
                                    .font(.subheadline)
                            }

                            ProgressView(value: goal.progress)
                                .tint(goal.isCompleted ? .shelfRead : .shelfProgress)
                                .background(Color.shelfProgress.opacity(0.1))
                                .frame(height: 8)
                                .scaleEffect(y: 2)
                        }
                        .padding()
                        .shelfCardStyle(radius: 16)
                        .padding(.horizontal)
                    }

                    if !viewModel.readingBooks.isEmpty {
                        BookSection(
                            title: "Reading Now",
                            books: viewModel.readingBooks,
                            color: .shelfProgress,
                            onSelect: { selectedBook = $0 },
                            onDelete: viewModel.deleteBook,
                            onFavorite: viewModel.toggleFavorite
                        )
                    }

                    if !viewModel.wantToReadBooks.isEmpty {
                        BookSection(
                            title: "Want to Read",
                            books: viewModel.wantToReadBooks,
                            color: .shelfProgress.opacity(0.7),
                            onSelect: { selectedBook = $0 },
                            onDelete: viewModel.deleteBook,
                            onFavorite: viewModel.toggleFavorite
                        )
                    }

                    if !viewModel.recentlyReadBooks.isEmpty {
                        BookSection(
                            title: "Finished Shelf",
                            books: viewModel.recentlyReadBooks,
                            color: .shelfRead,
                            onSelect: { selectedBook = $0 },
                            onDelete: viewModel.deleteBook,
                            onFavorite: viewModel.toggleFavorite
                        )
                    }
                }
                .padding(.vertical, 12)
            }
            .background(Color.shelfBackground.ignoresSafeArea())
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddBookSheet = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.shelfRead)
                                .frame(width: 32, height: 32)
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .accessibilityLabel("Add Book")
                }
            }
            .sheet(isPresented: $showAddBookSheet) {
                AddBookView { viewModel.addBook($0) }
            }
            .sheet(item: $selectedBook) { book in
                NavigationStack {
                    BookDetailView(viewModel: viewModel, book: book)
                }
            }
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Home Library")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.shelfProgress)
                    Text("Arrange, track and finish books like on real shelves")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "books.vertical.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.shelfRead)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [.white, .shelfBackground.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.shelfRead.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.shelfProgress.opacity(0.08), radius: 12, x: 0, y: 7)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}
