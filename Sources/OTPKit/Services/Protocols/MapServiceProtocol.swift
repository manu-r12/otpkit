//
//  MapServiceProtocol.swift
//  OTPKit
//
//  Created by Manu on 2025-01-27.
//

import Foundation
import MapKit
import SwiftUI

/// Protocol for map-related services
public protocol MapServiceProtocol: AnyObject {
    
    /// Selected map points for origin and destination
    var selectedMapPoints: TripMapMarkers { get }
    
    /// Current origin/destination state
    var originDestinationState: OriginDestinationState { get set }
    
    /// Origin coordinate
    var originCoordinate: CLLocationCoordinate2D? { get set }
    
    /// Destination coordinate
    var destinationCoordinate: CLLocationCoordinate2D? { get set }
    
    /// Origin name for display
    var originName: String { get set }
    
    /// Destination name for display
    var destinationName: String { get set }
    
    /// Appends a marker for the given location
    /// - Parameter location: The location to add a marker for
    func appendMarker(location: Location)
    
    /// Adds origin or destination data based on the current state
    func addOriginDestinationData()
    
    /// Removes origin or destination data based on the current state
    func removeOriginDestinationData()
    
    /// Selects and refreshes the coordinate based on the current origin/destination state
    func selectAndRefreshCoordinate()
    
    /// Generates a map polyline based on the selected itinerary
    /// - Parameter itinerary: The itinerary to generate polyline for
    /// - Returns: MapPolyline object or nil if no valid itinerary is selected
    func generateMapPolyline(for itinerary: Itinerary) -> MapPolyline?
} 