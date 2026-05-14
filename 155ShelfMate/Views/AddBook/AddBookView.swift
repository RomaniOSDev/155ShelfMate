import SwiftUI

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss

    let existingBook: Book?
    let onSave: (Book) -> Void

    @State private var title = ""
    @State private var author = ""
    @State private var genre: BookGenre = .fiction
    @State private var status: BookStatus = .wantToRead
    @State private var totalPages = 0
    @State private var currentPage = 0
    @State private var startDate = Date()
    @State private var finishDate = Date()
    @State private var rating: Int?
    @State private var review = ""
    @State private var isbn = ""
    @State private var publicationYear: Int?
    @State private var publisher = ""
    @State private var notes = ""
    @State private var isFavorite = false

    init(existingBook: Book? = nil, onSave: @escaping (Book) -> Void) {
        self.existingBook = existingBook
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .foregroundColor(.shelfProgress)
                    TextField("Author", text: $author)
                        .foregroundColor(.shelfProgress)
                    Picker("Genre", selection: $genre) {
                        ForEach(BookGenre.allCases, id: \.self) { genre in
                            Label(genre.rawValue, systemImage: genre.icon).tag(genre)
                        }
                    }
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(BookStatus.allCases, id: \.self) { status in
                            Label(status.rawValue, systemImage: status.icon).tag(status)
                        }
                    }

                    HStack {
                        Text("Total pages")
                        Spacer()
                        TextField("0", value: $totalPages, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                    }

                    if status == .reading {
                        HStack {
                            Text("Current page")
                            Spacer()
                            TextField("0", value: $currentPage, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }

                        DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                    }

                    if status == .read {
                        DatePicker("Finish date", selection: $finishDate, displayedComponents: .date)

                        Picker("Rating", selection: $rating) {
                            Text("None").tag(nil as Int?)
                            ForEach(1...5, id: \.self) { index in
                                Text(String(repeating: "★", count: index)).tag(index as Int?)
                            }
                        }
                    }
                }

                Section("Additional") {
                    TextField("ISBN", text: $isbn)

                    HStack {
                        Text("Publication year")
                        Spacer()
                        TextField("", value: $publicationYear, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 90)
                            .multilineTextAlignment(.trailing)
                    }

                    TextField("Publisher", text: $publisher)
                }

                Section("Review") {
                    TextEditor(text: $review)
                        .frame(height: 80)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }

                Section {
                    Toggle("Add to favorites", isOn: $isFavorite)
                        .tint(.shelfRead)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.shelfBackground)
            .navigationTitle(existingBook == nil ? "New Book" : "Edit Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.shelfRead)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBook()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .shelfAccentButtonStyle(radius: 8)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || totalPages <= 0)
                }
            }
            .onAppear {
                guard let book = existingBook else { return }
                title = book.title
                author = book.author
                genre = book.genre
                status = book.status
                totalPages = book.totalPages
                currentPage = book.currentPage ?? 0
                startDate = book.startDate ?? Date()
                finishDate = book.finishDate ?? Date()
                rating = book.rating
                review = book.review ?? ""
                isbn = book.isbn ?? ""
                publicationYear = book.publicationYear
                publisher = book.publisher ?? ""
                notes = book.notes ?? ""
                isFavorite = book.isFavorite
            }
            .tint(.shelfRead)
        }
    }

    private func saveBook() {
        let newBook = Book(
            id: existingBook?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            author: author.trimmingCharacters(in: .whitespacesAndNewlines),
            authorId: existingBook?.authorId,
            genre: genre,
            status: status,
            totalPages: max(1, totalPages),
            currentPage: status == .wantToRead ? nil : min(max(currentPage, 0), max(1, totalPages)),
            startDate: status == .reading ? startDate : existingBook?.startDate,
            finishDate: status == .read ? finishDate : nil,
            rating: status == .read ? rating : nil,
            review: review.isEmpty ? nil : review,
            isbn: isbn.isEmpty ? nil : isbn,
            publicationYear: publicationYear,
            publisher: publisher.isEmpty ? nil : publisher,
            notes: notes.isEmpty ? nil : notes,
            isFavorite: isFavorite,
            createdAt: existingBook?.createdAt ?? Date()
        )
        onSave(newBook)
        dismiss()
    }
}
