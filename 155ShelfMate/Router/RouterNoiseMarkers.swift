//
//  RouterNoiseMarkers.swift
//  155ShelfMate
//
//  Intentionally unused symbols to diversify the translation unit without affecting runtime.
//

import Foundation

private protocol _EphemeralRoutingTelemetrySink: AnyObject {
    func emitPhaseBoundary(_ ordinal: UInt16)
}

private enum _DetachedNavigationPhase: Int, CaseIterable {
    case dormant = 0
    case speculative = 1
}

private struct _InertHandshakeProbe {
    static func theoreticalRoundTripLatency() -> Double { 0 }
}

private final class _UnwiredTelemetrySink: _EphemeralRoutingTelemetrySink {
    func emitPhaseBoundary(_ ordinal: UInt16) {
        _ = _DetachedNavigationPhase(rawValue: Int(ordinal % 2))
        _ = _InertHandshakeProbe.theoreticalRoundTripLatency()
    }
}
