//
//  MapService.swift
//  OTPKit
//
//  Created by Manu on 2025-01-27.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

/// Concrete implementation of MapServiceProtocol
@Observable
public final class MapService: MapServiceProtocol {
    
    // MARK: - Properties
    
    private let locationService: LocationServiceProtocol
    
    // MARK: - Published Properties
    
    public private(set) var selectedMapPoints = TripMapMarkers()
    public var originDestinationState: OriginDestinationState = .origin
    public var originCoordinate: CLLocationCoordinate2D?
    public var destinationCoordinate: CLLocationCoordinate2D?
    public var originName = OriginDestinationState.origin.name.capitalized
    public var destinationName = OriginDestinationState.destination.name.capitalized
    
    // MARK: - Initialization
    
    /// Initializes a new instance of MapService
    /// - Parameter locationService: The location service for geocoding
    public init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
    }
    
    // MARK: - MapServiceProtocol
    
    public func appendMarker(location: Location) {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        
        let placeMark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = "Finding location..."
        
        let markerItem = MarkerItem(item: mapItem)
        
        selectedMapPoints[originDestinationState] = markerItem
        
        // Get accurate location name in background
        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        locationService.reverseGeoCode(clLocation) { [weak self] locationName in
            guard let self = self else { return }
            
            // Update marker with real location name once geocoding completes
            self.updateMarkerName(coordinate: coordinate, newName: locationName)
        }
    }
    
    public func addOriginDestinationData() {
        switch originDestinationState {
        case .origin:
            originName = selectedMapPoints.origin?.item.name ?? "Location unknown"
            originCoordinate = selectedMapPoints.origin?.item.placemark.coordinate
        case .destination:
            destinationName = selectedMapPoints.destination?.item.name ?? "Location unknown"
            destinationCoordinate = selectedMapPoints.destination?.item.placemark.coordinate
        }
    }
    
    public func removeOriginDestinationData() {
        switch originDestinationState {
        case .origin:
            originName = OriginDestinationState.origin.name.capitalized
            originCoordinate = nil
            selectedMapPoints.origin = nil
        case .destination:
            destinationName = OriginDestinationState.destination.name.capitalized
            destinationCoordinate = nil
            selectedMapPoints.destination = nil
        }
    }
    
    public func selectAndRefreshCoordinate() {
        switch originDestinationState {
        case .origin:
            guard let coordinate = selectedMapPoints.origin?.item.placemark.coordinate else {
                return
            }
            originCoordinate = coordinate
        case .destination:
            guard let coordinate = selectedMapPoints.destination?.item.placemark.coordinate else {
                return
            }
            destinationCoordinate = coordinate
        }
    }
    
    public func generateMapPolyline(for itinerary: Itinerary) -> MapPolyline? {
        // Use steps to calculate the Location Coordinate
        let coordinates = itinerary.legs.flatMap { leg in
            leg.decodePolyline()?.compactMap { coordinate in
                coordinate
            } ?? []
        }
        
        let coodinateExists = !coordinates.isEmpty
        
        guard coodinateExists else { return nil }
        
        return MapPolyline(coordinates: coordinates)
    }
    
    // MARK: - Private Methods
    
    private func updateMarkerName(coordinate: CLLocationCoordinate2D, newName: String) {
        let placeMark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.name = newName
        
        let updatedMarkerItem = MarkerItem(item: mapItem)
        
        switch originDestinationState {
        case .origin:
            originName = updatedMarkerItem.item.name ?? "...."
            selectedMapPoints.origin = updatedMarkerItem
        case .destination:
            destinationName = updatedMarkerItem.item.name ?? "...."
            selectedMapPoints.destination = updatedMarkerItem
        }
    }
} 
