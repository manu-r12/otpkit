//
//  LocationServiceProtocol.swift
//  OTPKit
//
//  Created by Manu on 2025-01-27.
//

import Foundation
import CoreLocation
import MapKit

/// Protocol for location-related services
public protocol LocationServiceProtocol: AnyObject {
    
    /// Current user location
    var currentLocation: Location? { get }
    
    /// Current region for search completer
    var currentRegion: MKCoordinateRegion? { get }
    
    /// Search completions
    var completions: [Location] { get }
    
    /// Initiates location authorization request
    func checkLocationAuthorization()
    
    /// Updates search query with debouncing
    /// - Parameter queryFragment: The search term
    func updateQuery(queryFragment: String)
    
    /// Performs reverse geocoding to get a readable location name
    /// - Parameters:
    ///   - location: The location to geocode
    ///   - completion: Completion handler with the location name
    func reverseGeoCode(_ location: CLLocation, completion: @escaping (String) -> Void)
    
    /// Formats a coordinate into a string representation
    /// - Parameter coordinate: The coordinate to format
    /// - Returns: A string representation of the coordinate
    func formatCoordinate(_ coordinate: CLLocationCoordinate2D?) -> String
} 