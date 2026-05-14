import SwiftUI

struct BookDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: ShelfMateViewModel
    let book: Book

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showUpdateProgressSheet = false
    @State private var progressPageInput = ""

    var body: some View {
        let currentBook = viewModel.books.first(where: { $0.id == book.id }) ?? book

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerView(book: currentBook)

                if currentBook.status == .reading {
                    progressView(book: currentBook)
                }

                infoGrid(book: currentBook)

                if let rating = currentBook.rating {
                    ratingView(rating: rating)
                }

                if let review = currentBook.review, !review.isEmpty {
                    reviewView(review: review)
                }

                actionButtons(book: currentBook)
            }
            .padding(.vertical)
        }
        .background(Color.shelfBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            AddBookView(existingBook: currentBook) { updatedBook in
                viewModel.updateBook(updatedBook)
            }
        }
        .alert("Delete book?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteBook(currentBook)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Update Progress", isPresented: $showUpdateProgressSheet) {
            TextField("Current page", text: $progressPageInput)
                .keyboardType(.numberPad)
            Button("Save") {
                if let page = Int(progressPageInput) {
                    viewModel.updateProgress(for: currentBook, currentPage: page)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your current page")
        }
    }

    private func headerView(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: book.genre.icon)
                    .foregroundColor(book.status.color)
                    .font(.largeTitle)

                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.shelfProgress)

                    Text(book.author)
                        .font(.title3)
                        .foregroundColor(.gray)
                }

                Spacer()

                if book.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.shelfRead)
                }
            }

            HStack {
                Text(book.genre.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(book.status.color.opacity(0.1))
                    .foregroundColor(book.status.color)
                    .cornerRadius(8)

                Text(book.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(book.status.color.opacity(0.1))
                    .foregroundColor(book.status.color)
                    .cornerRadius(8)
            }
        }
        .padding()
        .shelfCardStyle(radius: 16)
    }

    private func progressView(book: Book) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.headline)
                    .foregroundColor(.shelfProgress)

                Spacer()

                Text("\(book.progressPercentage)%")
                    .foregroundColor(.shelfRead)
                    .bold()
            }

            ProgressView(value: book.progress)
                .tint(.shelfRead)
                .background(Color.shelfProgress.opacity(0.1))

            HStack {
                Text("Read: \(book.currentPage ?? 0) of \(book.totalPages) pages")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                if let startDate = book.startDate {
                    Text("since \(formattedShortDate(startDate))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Button("Update Progress") {
                progressPageInput = String(book.currentPage ?? 0)
                showUpdateProgressSheet = true
            }
            .font(.caption)
            .foregroundColor(.shelfRead)
        }
        .padding()
        .shelfCardStyle(radius: 14)
        .padding(.horizontal)
    }

    private func infoGrid(book: Book) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            if let year = book.publicationYear {
                InfoBox(title: "Publication Year", value: "\(year)", icon: "calendar", color: .shelfRead)
            }

            if let publisher = book.publisher {
                InfoBox(title: "Publisher", value: publisher, icon: "building", color: .shelfRead)
            }

            if let isbn = book.isbn {
                InfoBox(title: "ISBN", value: isbn, icon: "barcode", color: .shelfRead)
            }

            if let finishDate = book.finishDate {
                InfoBox(title: "Finished", value: formattedShortDate(finishDate), icon: "checkmark.circle", color: .shelfRead)
            }
        }
        .padding(.horizontal)
    }

    private func ratingView(rating: Int) -> some View {
        VStack(alignment: .leading) {
            Text("My Rating")
                .font(.headline)
                .foregroundColor(.shelfProgress)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(.shelfRead)
                }
            }
        }
        .padding()
        .shelfCardStyle(radius: 14)
        .padding(.horizontal)
    }

    private func reviewView(review: String) -> some View {
        VStack(alignment: .leading) {
            Text("Review")
                .font(.headline)
                .foregroundColor(.shelfProgress)

            Text(review)
                .foregroundColor(.shelfProgress)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .shelfCardStyle(radius: 12)
        }
        .padding(.horizontal)
    }

    private func actionButtons(book: Book) -> some View {
        HStack {
            Button("Edit") {
                showEditSheet = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .shelfAccentButtonStyle(radius: 10)

            Button("Delete") {
                showDeleteConfirmation = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.shelfRead, lineWidth: 1)
            )
            .foregroundColor(.shelfRead)
        }
        .padding()
    }
}
