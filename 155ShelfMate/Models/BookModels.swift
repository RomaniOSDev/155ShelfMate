import SwiftUI

enum BookStatus: String, CaseIterable, Codable {
    case wantToRead = "Want to Read"
    case reading = "Reading"
    case read = "Read"
    case abandoned = "Abandoned"

    var icon: String {
        switch self {
        case .wantToRead: return "bookmark"
        case .reading: return "book.fill"
        case .read: return "checkmark.circle.fill"
        case .abandoned: return "xmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .wantToRead: return .shelfProgress.opacity(0.7)
        case .reading: return .shelfProgress
        case .read: return .shelfRead
        case .abandoned: return .gray
        }
    }
}

enum BookGenre: String, CaseIterable, Codable {
    case fiction = "Fiction"
    case nonFiction = "Non-fiction"
    case science = "Science"
    case history = "History"
    case biography = "Biography"
    case fantasy = "Fantasy"
    case sciFi = "Sci-Fi"
    case mystery = "Mystery"
    case romance = "Romance"
    case thriller = "Thriller"
    case poetry = "Poetry"
    case business = "Business"
    case selfHelp = "Self Help"
    case psychology = "Psychology"
    case art = "Art"
    case other = "Other"

    var icon: String {
        switch self {
        case .fiction: return "book.closed"
        case .nonFiction: return "text.book.closed"
        case .science: return "atom"
        case .history: return "clock"
        case .biography: return "person"
        case .fantasy: return "sparkles"
        case .sciFi: return "star"
        case .mystery: return "magnifyingglass"
        case .romance: return "heart"
        case .thriller: return "exclamationmark.triangle"
        case .poetry: return "quote.opening"
        case .business: return "briefcase"
        case .selfHelp: return "arrow.up"
        case .psychology: return "brain"
        case .art: return "paintpalette"
        case .other: return "books.vertical"
        }
    }
}

struct Author: Identifiable, Codable {
    let id: UUID
    var name: String
    var birthYear: Int?
    var deathYear: Int?
    var country: String?
    var biography: String?
}

struct Book: Identifiable, Codable {
    let id: UUID
    var title: String
    var author: String
    var authorId: UUID?
    var genre: BookGenre
    var status: BookStatus
    var totalPages: Int
    var currentPage: Int?
    var startDate: Date?
    var finishDate: Date?
    var rating: Int?
    var review: String?
    var isbn: String?
    var publicationYear: Int?
    var publisher: String?
    var notes: String?
    var isFavorite: Bool
    let createdAt: Date

    var progress: Double {
        guard totalPages > 0, let current = currentPage else { return 0 }
        return min(1, max(0, Double(current) / Double(totalPages)))
    }

    var progressPercentage: Int { Int(progress * 100) }

    var daysToRead: Int? {
        guard let start = startDate, let finish = finishDate else { return nil }
        return Calendar.current.dateComponents([.day], from: start, to: finish).day
    }

    var pagesPerDay: Double? {
        guard let days = daysToRead, days > 0 else { return nil }
        return Double(totalPages) / Double(days)
    }
}

struct ReadingSession: Identifiable, Codable {
    let id: UUID
    let bookId: UUID
    let date: Date
    let pagesRead: Int
    let duration: Int
    let notes: String?
}

struct ReadingGoal: Identifiable, Codable {
    let id: UUID
    var year: Int
    var targetBooks: Int
    var currentBooks: Int
    var targetPages: Int?
    var currentPages: Int
    var isCompleted: Bool

    var progress: Double {
        guard targetBooks > 0 else { return 0 }
        return min(1, max(0, Double(currentBooks) / Double(targetBooks)))
    }
}

struct Quote: Identifiable, Codable {
    let id: UUID
    let bookId: UUID
    let bookTitle: String
    let text: String
    let page: Int?
    var isFavorite: Bool
    let createdAt: Date
}

struct ReadingChallenge: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var targetBooks: Int
    var currentBooks: Int
    var deadline: Date?
    var isCompleted: Bool
    let createdAt: Date
}
