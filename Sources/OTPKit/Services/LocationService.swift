//
//  LocationService.swift
//  OTPKit
//
//  Created by Manu on 2025-01-27.
//

import Foundation
import CoreLocation
import MapKit

/// Concrete implementation of LocationServiceProtocol
public final class LocationService: NSObject, LocationServiceProtocol {
    
    // MARK: - Properties
    
    private let locationManager: CLLocationManager
    private let searchCompleter: MKLocalSearchCompleter
    private let debounceInterval: TimeInterval
    private var debounceTimer: Timer?
    private var currentLocations = [CLLocation]()
    
    // MARK: - Published Properties
    
    public private(set) var currentLocation: Location?
    public private(set) var currentRegion: MKCoordinateRegion?
    public private(set) var completions = [Location]()
    
    // MARK: - Initialization
    
    /// Initializes a new instance of LocationService
    /// - Parameters:
    ///   - locationManager: The location manager for handling user location
    ///   - searchCompleter: The search completer for location search functionality
    public init(locationManager: CLLocationManager, searchCompleter: MKLocalSearchCompleter) {
        self.locationManager = locationManager
        self.searchCompleter = searchCompleter
        self.debounceInterval = 1
        super.init()
        
        searchCompleter.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    deinit {
        debounceTimer?.invalidate()
        searchCompleter.cancel()
    }
    
    // MARK: - LocationServiceProtocol
    
    public func checkLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    public func updateQuery(queryFragment: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) { [weak self] _ in
            guard let self else { return }
            searchCompleter.resultTypes = .query
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    public func reverseGeoCode(_ location: CLLocation, completion: @escaping (String) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { placeMarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion("Unknown Location")
                return
            }
            
            guard let placeMark = placeMarks?.first else {
                completion("Unknown Location")
                return
            }
            
            let locationName = self.formatLocationName(from: placeMark)
            completion(locationName)
        }
    }
    
    public func formatCoordinate(_ coordinate: CLLocationCoordinate2D?) -> String {
        guard let coordinate else { return "" }
        return String(format: "%.4f,%.4f", coordinate.latitude, coordinate.longitude)
    }
    
    // MARK: - Private Methods
    
    private func updateCompleterRegion() {
        if let region = currentRegion {
            searchCompleter.region = region
        }
    }
    
    private func formatLocationName(from placeMark: CLPlacemark) -> String {
        if let name = placeMark.name {
            return name
        }
        
        // street address associated with this placed mark
        if let thoroughfare = placeMark.thoroughfare {
            if let subToroughFare = placeMark.subThoroughfare {
                return "\(subToroughFare) \(thoroughfare)"
            }
            return thoroughfare
        }
        
        // Try city name if cannot get the street address
        if let locality = placeMark.locality {
            return locality
        }
        
        return "Unknown Location"
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationService: MKLocalSearchCompleterDelegate {
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions.removeAll()
        
        for result in completer.results {
            let searchRequest = MKLocalSearch.Request(completion: result)
            let search = MKLocalSearch(request: searchRequest)
            
            search.start { [weak self] response, error in
                guard let self, let response else {
                    if let error {
                        print("Error performing local search: \(error)")
                    }
                    return
                }
                
                if let mapItem = response.mapItems.first {
                    let completion = Location(
                        title: result.title,
                        subTitle: result.subtitle,
                        latitude: mapItem.placemark.coordinate.latitude,
                        longitude: mapItem.placemark.coordinate.longitude
                    )
                    
                    DispatchQueue.main.async {
                        self.completions.append(completion)
                    }
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Check and Cache last location to avoid multiple geocoding requests
        let isLatestLocation = currentLocations.contains {
            $0.coordinate.latitude == location.coordinate.latitude
            && $0.coordinate.longitude == location.coordinate.longitude
        }
        
        guard !isLatestLocation else {
            return
        }
        currentLocations.append(location)
        
        reverseGeoCode(location) { [weak self] locationName in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.currentLocation = Location(
                    title: locationName,
                    subTitle: "Your current location",
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                self.currentRegion = MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 1000,
                    longitudinalMeters: 1000
                )
                self.updateCompleterRegion()
            }
        }
    }
} 