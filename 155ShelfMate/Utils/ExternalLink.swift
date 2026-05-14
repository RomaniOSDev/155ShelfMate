import Foundation

enum ExternalLink: String, CaseIterable {
    case privacyPolicy = "https://www.termsfeed.com/live/6f9e19a4-c431-4162-bce2-b146f7cb5e35"
    case terms = "https://www.termsfeed.com/live/94267dc1-ea2c-4317-9ae0-96a84b1ddd0c"

    var title: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .terms:
            return "Terms"
        }
    }

    var url: URL? {
        URL(string: rawValue)
    }
}
