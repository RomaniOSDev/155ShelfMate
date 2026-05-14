import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track Every Book",
            subtitle: "Add books, set status, and keep your personal reading catalog organized.",
            icon: "books.vertical.fill"
        ),
        OnboardingPage(
            title: "Follow Your Progress",
            subtitle: "Update pages, watch goals grow, and build a steady reading habit.",
            icon: "chart.bar.xaxis"
        ),
        OnboardingPage(
            title: "Save Insights",
            subtitle: "Rate books, write notes, and collect favorite quotes in one place.",
            icon: "quote.opening"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 22) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(LinearGradient.shelfAccent.opacity(0.2))
                                .frame(width: 180, height: 180)
                            Image(systemName: page.icon)
                                .font(.system(size: 62, weight: .semibold))
                                .foregroundStyle(LinearGradient.shelfAccent)
                        }

                        VStack(spacing: 10) {
                            Text(page.title)
                                .font(.largeTitle.bold())
                                .foregroundColor(.shelfProgress)
                                .multilineTextAlignment(.center)
                            Text(page.subtitle)
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }

                        Spacer()
                    }
                    .tag(index)
                    .padding(.bottom, 20)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: 12) {
                Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                    if currentPage < pages.count - 1 {
                        withAnimation(.easeInOut) { currentPage += 1 }
                    } else {
                        hasSeenOnboarding = true
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .shelfAccentButtonStyle(radius: 14)

                Button("Skip") {
                    hasSeenOnboarding = true
                }
                .foregroundColor(.shelfRead)
                .opacity(currentPage == pages.count - 1 ? 0 : 1)
                .disabled(currentPage == pages.count - 1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.shelfBackground.ignoresSafeArea())
    }
}

private struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
}
