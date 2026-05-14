import SwiftUI

struct GoalCard: View {
    let goal: ReadingGoal
    private var progressValue: Double { min(max(goal.progress, 0), 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(goal.year == Calendar.current.component(.year, from: Date()) ? "Current Goal" : "Goal for \(goal.year)")
                    .font(.headline)
                    .foregroundColor(.shelfProgress)

                Spacer()

                if goal.isCompleted {
                    Text("Completed")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.shelfRead.opacity(0.1))
                        .foregroundColor(.shelfRead)
                        .cornerRadius(8)
                }
            }

            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Color.shelfProgress.opacity(0.12), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: progressValue)
                        .stroke(Color.shelfRead, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(progressValue * 100))%")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.shelfProgress)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("\(goal.currentBooks)/\(goal.targetBooks) books")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.shelfProgress)

                    ProgressView(value: progressValue)
                        .tint(.shelfRead)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let targetPages = goal.targetPages {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Label("Pages", systemImage: "doc.text")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(goal.currentPages)/\(targetPages)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.shelfProgress)
                    }
                    ProgressView(value: Double(goal.currentPages), total: Double(max(1, targetPages)))
                        .tint(.shelfProgress)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
