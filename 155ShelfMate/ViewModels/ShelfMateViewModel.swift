import Foundation
import Combine

final class ShelfMateViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var authors: [Author] = []
    @Published var goals: [ReadingGoal] = []
    @Published var quotes: [Quote] = []
    @Published var readingSessions: [ReadingSession] = []
    @Published var challenges: [ReadingChallenge] = []

    var totalBooks: Int { books.count }
    var readBooksCount: Int { books.filter { $0.status == .read }.count }
    var readingBooksCount: Int { books.filter { $0.status == .reading }.count }
    var wantToReadBooksCount: Int { books.filter { $0.status == .wantToRead }.count }
    var totalPagesRead: Int { books.filter { $0.status == .read }.reduce(0) { $0 + $1.totalPages } }

    var averageRating: Double {
        let ratedBooks = books.filter { $0.rating != nil && $0.status == .read }
        guard !ratedBooks.isEmpty else { return 0 }
        let sum = ratedBooks.reduce(0) { $0 + ($1.rating ?? 0) }
        return Double(sum) / Double(ratedBooks.count)
    }

    var readingBooks: [Book] {
        books.filter { $0.status == .reading }
            .sorted { $0.progress > $1.progress }
    }

    var wantToReadBooks: [Book] {
        books.filter { $0.status == .wantToRead }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var recentlyReadBooks: [Book] {
        books.filter { $0.status == .read }
            .sorted { ($0.finishDate ?? $0.createdAt) > ($1.finishDate ?? $1.createdAt) }
            .prefix(10)
            .map { $0 }
    }

    var currentGoal: ReadingGoal? {
        let currentYear = Calendar.current.component(.year, from: Date())
        return goals.first { $0.year == currentYear }
    }

    struct MonthlyStat: Identifiable {
        let id = UUID()
        let date: Date
        let month: String
        let count: Int
    }

    var monthlyStats: [MonthlyStat] {
        let calendar = Calendar.current
        let readBooks = books.filter { $0.status == .read && $0.finishDate != nil }
        let grouped = Dictionary(grouping: readBooks) { book in
            let components = calendar.dateComponents([.year, .month], from: book.finishDate ?? Date())
            return calendar.date(from: components) ?? Date()
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "en_US")

        return grouped.map { date, books in
            MonthlyStat(date: date, month: formatter.string(from: date), count: books.count)
        }.sorted { $0.date < $1.date }
    }

    struct GenreStat: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let count: Int
    }

    var topGenres: [GenreStat] {
        let grouped = Dictionary(grouping: books.filter { $0.status == .read }, by: { $0.genre })
        return grouped.map { genre, books in
            GenreStat(name: genre.rawValue, icon: genre.icon, count: books.count)
        }
        .sorted { $0.count > $1.count }
        .prefix(5)
        .map { $0 }
    }

    struct AuthorStat: Identifiable {
        let id = UUID()
        let name: String
        let count: Int
    }

    var topAuthors: [AuthorStat] {
        let grouped = Dictionary(grouping: books.filter { $0.status == .read }, by: { $0.author })
        return grouped.map { author, books in
            AuthorStat(name: author, count: books.count)
        }
        .sorted { $0.count > $1.count }
        .prefix(5)
        .map { $0 }
    }

    func addBook(_ book: Book) {
        books.append(book)
        updateGoal()
        saveToUserDefaults()
    }

    func updateBook(_ book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index] = book
        updateGoal()
        saveToUserDefaults()
    }

    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        updateGoal()
        saveToUserDefaults()
    }

    func toggleFavorite(_ book: Book) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index].isFavorite.toggle()
        saveToUserDefaults()
    }

    func updateProgress(for book: Book, currentPage: Int) {
        guard let index = books.firstIndex(where: { $0.id == book.id }) else { return }
        books[index].currentPage = min(max(0, currentPage), books[index].totalPages)
        if books[index].currentPage == books[index].totalPages {
            books[index].status = .read
            books[index].finishDate = Date()
        }
        updateGoal()
        saveToUserDefaults()
    }

    func addGoal(_ goal: ReadingGoal) {
        goals.append(goal)
        saveToUserDefaults()
    }

    func deleteGoal(_ goal: ReadingGoal) {
        goals.removeAll { $0.id == goal.id }
        saveToUserDefaults()
    }

    func addQuote(_ quote: Quote) {
        quotes.append(quote)
        saveToUserDefaults()
    }

    func deleteQuote(_ quote: Quote) {
        quotes.removeAll { $0.id == quote.id }
        saveToUserDefaults()
    }

    func toggleFavoriteQuote(_ quote: Quote) {
        guard let index = quotes.firstIndex(where: { $0.id == quote.id }) else { return }
        quotes[index].isFavorite.toggle()
        saveToUserDefaults()
    }

    private func updateGoal() {
        let readCount = readBooksCount
        let totalPages = totalPagesRead

        if let index = goals.firstIndex(where: { $0.year == Calendar.current.component(.year, from: Date()) }) {
            goals[index].currentBooks = readCount
            goals[index].currentPages = totalPages
            goals[index].isCompleted = readCount >= goals[index].targetBooks
        }
    }

    private let booksKey = "shelfmate_books"
    private let authorsKey = "shelfmate_authors"
    private let goalsKey = "shelfmate_goals"
    private let quotesKey = "shelfmate_quotes"
    private let sessionsKey = "shelfmate_sessions"
    private let challengesKey = "shelfmate_challenges"

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(books) { UserDefaults.standard.set(encoded, forKey: booksKey) }
        if let encoded = try? JSONEncoder().encode(authors) { UserDefaults.standard.set(encoded, forKey: authorsKey) }
        if let encoded = try? JSONEncoder().encode(goals) { UserDefaults.standard.set(encoded, forKey: goalsKey) }
        if let encoded = try? JSONEncoder().encode(quotes) { UserDefaults.standard.set(encoded, forKey: quotesKey) }
        if let encoded = try? JSONEncoder().encode(readingSessions) { UserDefaults.standard.set(encoded, forKey: sessionsKey) }
        if let encoded = try? JSONEncoder().encode(challenges) { UserDefaults.standard.set(encoded, forKey: challengesKey) }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: booksKey), let decoded = try? JSONDecoder().decode([Book].self, from: data) { books = decoded }
        if let data = UserDefaults.standard.data(forKey: authorsKey), let decoded = try? JSONDecoder().decode([Author].self, from: data) { authors = decoded }
        if let data = UserDefaults.standard.data(forKey: goalsKey), let decoded = try? JSONDecoder().decode([ReadingGoal].self, from: data) { goals = decoded }
        if let data = UserDefaults.standard.data(forKey: quotesKey), let decoded = try? JSONDecoder().decode([Quote].self, from: data) { quotes = decoded }
        if let data = UserDefaults.standard.data(forKey: sessionsKey), let decoded = try? JSONDecoder().decode([ReadingSession].self, from: data) { readingSessions = decoded }
        if let data = UserDefaults.standard.data(forKey: challengesKey), let decoded = try? JSONDecoder().decode([ReadingChallenge].self, from: data) { challenges = decoded }

        if books.isEmpty { loadDemoData() }
    }

    private func loadDemoData() {
        let book1 = Book(
            id: UUID(),
            title: "1984",
            author: "George Orwell",
            authorId: nil,
            genre: .fiction,
            status: .read,
            totalPages: 328,
            currentPage: 328,
            startDate: Date().addingTimeInterval(-86_400 * 30),
            finishDate: Date().addingTimeInterval(-86_400 * 10),
            rating: 5,
            review: "A strong dystopian classic.",
            isbn: "9780451524935",
            publicationYear: 1949,
            publisher: "Secker & Warburg",
            notes: nil,
            isFavorite: true,
            createdAt: Date()
        )

        let book2 = Book(
            id: UUID(),
            title: "Sapiens",
            author: "Yuval Noah Harari",
            authorId: nil,
            genre: .nonFiction,
            status: .reading,
            totalPages: 520,
            currentPage: 234,
            startDate: Date().addingTimeInterval(-86_400 * 15),
            finishDate: nil,
            rating: nil,
            review: nil,
            isbn: "9780062316097",
            publicationYear: 2011,
            publisher: "Harvill Secker",
            notes: "Insightful and broad historical lens.",
            isFavorite: false,
            createdAt: Date()
        )

        let book3 = Book(
            id: UUID(),
            title: "The Master and Margarita",
            author: "Mikhail Bulgakov",
            authorId: nil,
            genre: .fiction,
            status: .wantToRead,
            totalPages: 480,
            currentPage: nil,
            startDate: nil,
            finishDate: nil,
            rating: nil,
            review: nil,
            isbn: "9780679760807",
            publicationYear: 1967,
            publisher: "YMCA Press",
            notes: nil,
            isFavorite: true,
            createdAt: Date()
        )

        books = [book1, book2, book3]
        goals = [
            ReadingGoal(
                id: UUID(),
                year: Calendar.current.component(.year, from: Date()),
                targetBooks: 20,
                currentBooks: 1,
                targetPages: 5000,
                currentPages: 328,
                isCompleted: false
            )
        ]
        quotes = [
            Quote(
                id: UUID(),
                bookId: book1.id,
                bookTitle: book1.title,
                text: "Who controls the past controls the future. Who controls the present controls the past.",
                page: 35,
                isFavorite: true,
                createdAt: Date()
            )
        ]
        saveToUserDefaults()
    }
}
