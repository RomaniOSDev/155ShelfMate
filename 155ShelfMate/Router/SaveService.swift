//
//  SaveService.swift
//  155ShelfMate
//

import Foundation

enum IndexedLocationDefaults {
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: "LastUrl") }
        set { UserDefaults.standard.set(newValue, forKey: "LastUrl") }
    }
}
