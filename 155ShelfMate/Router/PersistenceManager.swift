//
//  PersistenceManager.swift
//  155ShelfMate
//

import Foundation

final class LaunchPreferenceVault {
    static let shared = LaunchPreferenceVault()

    private let savedUrlKey = "LastUrl"
    private let hasShownContentViewKey = "HasShownContentView"
    private let hasSuccessfulWebViewLoadKey = "HasSuccessfulWebViewLoad"

    var savedUrl: String? {
        get {
            if let url = IndexedLocationDefaults.lastUrl {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: savedUrlKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: savedUrlKey)
                if let url = URL(string: urlString) {
                    IndexedLocationDefaults.lastUrl = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: savedUrlKey)
                IndexedLocationDefaults.lastUrl = nil
            }
        }
    }

    var hasShownContentView: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasShownContentViewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasShownContentViewKey)
        }
    }

    var hasSuccessfulWebViewLoad: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSuccessfulWebViewLoadKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSuccessfulWebViewLoadKey)
        }
    }

    private init() {}
}
