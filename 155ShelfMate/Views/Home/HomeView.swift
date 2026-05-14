import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: ShelfMateViewModel
    @Binding var selectedTab: Int

    @State private var selectedBook: Book?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    welcomeWidget
                    quickActionsWidget
                    nowReadingWidget
                    goalWidget
                    highlightsWidget
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color.shelfBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .sheet(item: $selectedBook) { book in
                NavigationStack {
                    BookDetailView(viewModel: viewModel, book: book)
                }
            }
        }
    }

    private var welcomeWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reading Dashboard")
                .font(.title2.weight(.bold))
                .foregroundColor(.shelfProgress)
            Text("Everything you need today: progress, goals, and quick access.")
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack(spacing: 10) {
                miniMetric(title: "Books", value: "\(viewModel.totalBooks)", icon: "books.vertical.fill", color: .shelfProgress)
                miniMetric(title: "Read", value: "\(viewModel.readBooksCount)", icon: "checkmark.circle.fill", color: .shelfRead)
                miniMetric(title: "Pages", value: "\(viewModel.totalPagesRead)", icon: "doc.text.fill", color: .shelfProgress)
            }
        }
        .padding(16)
        .shelfCardStyle(radius: 16)
    }

    private var quickActionsWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.shelfProgress)

            HStack(spacing: 10) {
                quickButton(title: "Library", icon: "books.vertical.fill") { selectedTab = 1 }
                quickButton(title: "Stats", icon: "chart.bar.fill") { selectedTab = 2 }
                quickButton(title: "Goals", icon: "target") { selectedTab = 3 }
                quickButton(title: "Quotes", icon: "quote.opening") { selectedTab = 4 }
            }
        }
        .padding(16)
        .shelfCardStyle(radius: 16)
    }

    private var nowReadingWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Continue Reading")
                    .font(.headline)
                    .foregroundColor(.shelfProgress)
                Spacer()
                Button("Open Library") { selectedTab = 1 }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.shelfRead)
            }

            if viewModel.readingBooks.isEmpty {
                emptyLine(text: "No books in progress yet.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(viewModel.readingBooks.prefix(5)) { book in
                            BookCard(book: book, color: .shelfProgress)
                                .onTapGesture { selectedBook = book }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .shelfCardStyle(radius: 16)
    }

    private var goalWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Year Goal")
                    .font(.headline)
                    .foregroundColor(.shelfProgress)
                Spacer()
                Button("Edit Goals") { selectedTab = 3 }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.shelfRead)
            }

            if let goal = viewModel.currentGoal {
                Text("\(goal.currentBooks) of \(goal.targetBooks) books")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.shelfProgress)
                ProgressView(value: goal.progress)
                    .tint(goal.isCompleted ? .shelfRead : .shelfProgress)
                    .scaleEffect(y: 1.7)
                Text(goal.isCompleted ? "Great job, goal completed." : "Keep going, you are on track.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                emptyLine(text: "No goal for this year. Add one now.")
            }
        }
        .padding(16)
        .shelfCardStyle(radius: 16)
    }

    private var highlightsWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Highlights")
                    .font(.headline)
                    .foregroundColor(.shelfProgress)
                Spacer()
                Button("Open Quotes") { selectedTab = 4 }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.shelfRead)
            }

            if let quote = viewModel.quotes.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text(quote.bookTitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("“\(quote.text)”")
                        .font(.body.italic())
                        .foregroundColor(.shelfProgress)
                        .lineLimit(4)
                    if let page = quote.page {
                        Text("Page \(page)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.shelfBackground)
                .cornerRadius(12)
            } else {
                emptyLine(text: "Add your first quote to see highlights.")
            }
        }
        .padding(16)
        .shelfCardStyle(radius: 16)
    }

    private func miniMetric(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .foregroundColor(.shelfProgress)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.shelfBackground)
        .cornerRadius(10)
    }

    private func quickButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .shelfAccentButtonStyle(radius: 10)
        }
    }

    private func emptyLine(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
    }
}
