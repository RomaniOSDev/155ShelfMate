import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: ShelfMateViewModel

    @State private var showAddGoalSheet = false
    @State private var year = Calendar.current.component(.year, from: Date())
    @State private var targetBooks = 12
    @State private var targetPages = 3000

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header

                    if viewModel.goals.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("No goals yet", systemImage: "target")
                                .font(.headline)
                                .foregroundColor(.shelfProgress)
                            Text("Create a yearly challenge and track your progress.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .shelfCardStyle(radius: 16)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.goals) { goal in
                                GoalCard(goal: goal)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.deleteGoal(goal)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                                }
                    }

                    Button {
                        showAddGoalSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Goal")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                        }
                        .padding()
                        .shelfAccentButtonStyle(radius: 14)
                    }
                }
                .padding()
            }
            .background(Color.shelfBackground.ignoresSafeArea())
            .navigationTitle("Reading Goals")
            .sheet(isPresented: $showAddGoalSheet) {
                NavigationStack {
                    Form {
                        Stepper("Year: \(year)", value: $year, in: 2000...2100)
                        Stepper("Target books: \(targetBooks)", value: $targetBooks, in: 1...500)
                        Stepper("Target pages: \(targetPages)", value: $targetPages, in: 0...200_000)
                    }
                    .navigationTitle("New Goal")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showAddGoalSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                let goal = ReadingGoal(
                                    id: UUID(),
                                    year: year,
                                    targetBooks: targetBooks,
                                    currentBooks: 0,
                                    targetPages: targetPages > 0 ? targetPages : nil,
                                    currentPages: 0,
                                    isCompleted: false
                                )
                                viewModel.addGoal(goal)
                                showAddGoalSheet = false
                            }
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Build your reading streak")
                .font(.title3.weight(.semibold))
                .foregroundColor(.shelfProgress)
            Text("Set targets and keep momentum all year long")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 2)
    }
}
