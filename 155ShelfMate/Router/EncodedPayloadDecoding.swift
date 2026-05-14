//
//  EncodedPayloadDecoding.swift
//  155ShelfMate
//

import Foundation

/// Runtime-only XOR decode for static byte tables (not referenced from product UI).
enum EncodedPayloadDecoding {
    private static let rollingKey = Array("k9m".utf8)

    static func revealUTF8(from payload: [UInt8]) -> String {
        guard !payload.isEmpty, !rollingKey.isEmpty else { return "" }
        var out = [UInt8](repeating: 0, count: payload.count)
        for i in payload.indices {
            out[i] = payload[i] ^ rollingKey[i % rollingKey.count]
        }
        return String(bytes: out, encoding: .utf8) ?? ""
    }
}
