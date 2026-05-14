import SwiftUI
import UIKit
import StoreKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        rateApp()
                    } label: {
                        settingsRow(title: "Rate Us", icon: "star.fill")
                    }
                    .buttonStyle(.plain)
                }

                Section("Legal") {
                    Button {
                        openLink(.privacyPolicy)
                    } label: {
                        settingsRow(title: "Privacy Policy", icon: "lock.shield")
                    }
                    .buttonStyle(.plain)

                    Button {
                        openLink(.terms)
                    } label: {
                        settingsRow(title: "Terms", icon: "doc.text")
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.shelfBackground.ignoresSafeArea())
            .navigationTitle("Settings")
        }
    }

    private func settingsRow(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.shelfRead)
                .frame(width: 24)
            Text(title)
                .foregroundColor(.shelfProgress)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding(.vertical, 4)
    }

    private func openLink(_ link: ExternalLink) {
        switch link {
        case .privacyPolicy:
            if let url = URL(string: "https://example.com/privacy-policy") {
                UIApplication.shared.open(url)
            }
        case .terms:
            if let url = link.url {
                UIApplication.shared.open(url)
            }
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
