//
//  TripPlannerServiceFactory.swift
//  OTPKit
//
//  Created by Manu on 2025-01-27.
//

import Foundation
import CoreLocation
import MapKit

/// Factory for creating TripPlannerCoordinatorService with all its dependencies
public final class TripPlannerServiceFactory {
    
    /// Creates a TripPlannerCoordinatorService with default implementations
    /// - Parameter baseURL: The base URL for the OTP API
    /// - Returns: A configured TripPlannerCoordinatorService
    public static func create(baseURL: URL) -> TripPlannerCoordinatorService {
        let locationManager = CLLocationManager()
        let searchCompleter = MKLocalSearchCompleter()
        let apiClient = RestAPI(baseURL: baseURL)
        
        let locationService = LocationService(
            locationManager: locationManager,
            searchCompleter: searchCompleter
        )
        
        let mapService = MapService(locationService: locationService)
        let tripPlannerService = TripPlannerAPIService(apiClient: apiClient)
        
        return TripPlannerCoordinatorService(
            locationService: locationService,
            mapService: mapService,
            tripPlannerService: tripPlannerService
        )
    }
} 