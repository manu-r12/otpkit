//
//  TripMapMarkers.swift
//  OTPKit
//
//  Created by Manu on 2025-06-24.
//

import Foundation

/// Simple container for trip planning map markers
public struct TripMapMarkers {
    public var origin: MarkerItem?
    public var destination: MarkerItem?

    public init() {
        self.origin = nil
        self.destination = nil
    }

    /// Get all non-nil markers for map display
    public var allMarkers: [MarkerItem] {
        [origin, destination].compactMap { $0 }
    }

    /// Reset both markers
    public mutating func reset() {
        origin = nil
        destination = nil
    }

    /// Subscript for compatibility with OriginDestinationState
    public subscript(state: OriginDestinationState) -> MarkerItem? {
        get {
            switch state {
            case .origin: return origin
            case .destination: return destination
            }
        }
        set {
            switch state {
            case .origin: origin = newValue
            case .destination: destination = newValue
            }
        }
    }
}
