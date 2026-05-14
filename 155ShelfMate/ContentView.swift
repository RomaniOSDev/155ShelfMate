import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ShelfMateViewModel()
    @State private var selectedTab = 0
    @AppStorage("shelfmate_has_seen_onboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                mainTabs
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
        .onAppear {
            viewModel.loadFromUserDefaults()
        }
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            LibraryView(viewModel: viewModel)
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
                .tag(1)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)

            GoalsView(viewModel: viewModel)
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(3)

            QuotesView(viewModel: viewModel)
                .tabItem {
                    Label("Quotes", systemImage: "quote.opening")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .tint(.shelfRead)
        .background(Color.shelfBackground)
    }
}

#Preview {
    ContentView()
}
