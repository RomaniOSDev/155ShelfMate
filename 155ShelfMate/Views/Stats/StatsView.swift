import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: ShelfMateViewModel
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    LazyVGrid(columns: columns, spacing: 12) {
                        StatCard(title: "Total Books", value: "\(viewModel.totalBooks)", icon: "books.vertical.fill", color: .shelfProgress)
                        StatCard(title: "Read", value: "\(viewModel.readBooksCount)", icon: "checkmark.circle.fill", color: .shelfRead)
                        StatCard(title: "Total Pages", value: "\(viewModel.totalPagesRead)", icon: "doc.text.fill", color: .shelfProgress)
                        StatCard(title: "Average Rating", value: String(format: "%.1f", viewModel.averageRating), icon: "star.fill", color: .shelfRead)
                    }
                    .padding(14)
                    .cardContainer()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Books by Month")
                            .font(.headline)
                            .foregroundColor(.shelfProgress)

                        if viewModel.monthlyStats.isEmpty {
                            placeholder(text: "No finished books yet")
                        } else {
                            Chart {
                                ForEach(viewModel.monthlyStats) { data in
                                    BarMark(
                                        x: .value("Month", data.month),
                                        y: .value("Books", data.count)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.shelfRead, .shelfProgress],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .annotation(position: .top) {
                                        Text("\(data.count)")
                                            .font(.caption2)
                                            .foregroundColor(.shelfProgress)
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .frame(height: 170)
                        }
                    }
                    .padding(16)
                    .cardContainer()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Genres")
                            .font(.headline)
                            .foregroundColor(.shelfProgress)

                        if viewModel.topGenres.isEmpty {
                            placeholder(text: "Add and finish books to see genre stats")
                        } else {
                            let maxGenreCount = max(viewModel.topGenres.map(\.count).max() ?? 1, 1)
                            ForEach(viewModel.topGenres) { genre in
                                VStack(spacing: 6) {
                                    HStack {
                                        Image(systemName: genre.icon)
                                            .foregroundColor(.shelfRead)
                                            .frame(width: 22)
                                        Text(genre.name)
                                            .foregroundColor(.shelfProgress)
                                        Spacer()
                                        Text("\(genre.count)")
                                            .foregroundColor(.shelfRead)
                                            .bold()
                                    }

                                    ProgressView(value: Double(genre.count), total: Double(maxGenreCount))
                                        .tint(.shelfRead)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding(16)
                    .cardContainer()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Authors")
                            .font(.headline)
                            .foregroundColor(.shelfProgress)

                        if viewModel.topAuthors.isEmpty {
                            placeholder(text: "Author stats will appear here")
                        } else {
                            let maxAuthorCount = max(viewModel.topAuthors.map(\.count).max() ?? 1, 1)
                            ForEach(viewModel.topAuthors) { author in
                                VStack(spacing: 6) {
                                    HStack {
                                        Text(author.name)
                                            .foregroundColor(.shelfProgress)
                                        Spacer()
                                        Text("\(author.count) books")
                                            .foregroundColor(.shelfRead)
                                    }

                                    ProgressView(value: Double(author.count), total: Double(maxAuthorCount))
                                        .tint(.shelfProgress)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding(16)
                    .cardContainer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .background(Color.shelfBackground.ignoresSafeArea())
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Track your reading rhythm")
                .font(.title3.weight(.semibold))
                .foregroundColor(.shelfProgress)
            Text("Your progress and habits in one clean dashboard")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func placeholder(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }
}

private extension View {
    func cardContainer() -> some View {
        self.shelfCardStyle(radius: 16)
    }
}
