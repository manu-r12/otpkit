//
//  TripPlannerCoordinatorService.swift
//  OTPKit
//
//  Created by Manu on 2025-01-27.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

/// Coordinator service that combines all individual services and manages UI state
@Observable
public final class TripPlannerCoordinatorService: NSObject {
    
    // MARK: - Dependencies
    
    private let locationService: LocationServiceProtocol
    private let mapService: MapServiceProtocol
    private let tripPlannerService: TripPlannerServiceProtocol
    
    // MARK: - UI State Properties (moved from original TripPlannerService)
    
    // Trip Planner UI States
    public var isFetchingResponse = false
    public var tripPlannerErrorMessage: String?
    public var selectedItinerary: Itinerary?
    public var isStepsViewPresented = false
    
    // Sheet States
    public var isOriginDestinationSheetPresented = false
    
    // Date and Time
    public var selectedDate: Date?
    public var selectedTime: Date?
    
    // Map States
    public var isMapMarkingMode = false
    public var currentCameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // MARK: - Computed Properties
    
    /// Current plan response from the API service
    public var planResponse: OTPResponse? {
        tripPlannerService.planResponse
    }
    
    /// Current user location from location service
    public var currentLocation: Location? {
        locationService.currentLocation
    }
    
    /// Search completions from location service
    public var completions: [Location] {
        locationService.completions
    }
    
    /// Origin coordinate from map service
    public var originCoordinate: CLLocationCoordinate2D? {
        get { mapService.originCoordinate }
        set { mapService.originCoordinate = newValue }
    }
    
    /// Destination coordinate from map service
    public var destinationCoordinate: CLLocationCoordinate2D? {
        get { mapService.destinationCoordinate }
        set { mapService.destinationCoordinate = newValue }
    }
    
    /// Origin name from map service
    public var originName: String {
        get { mapService.originName }
        set { mapService.originName = newValue }
    }
    
    /// Destination name from map service
    public var destinationName: String {
        get { mapService.destinationName }
        set { mapService.destinationName = newValue }
    }
    
    /// Origin destination state from map service
    public var originDestinationState: OriginDestinationState {
        get { mapService.originDestinationState }
        set { mapService.originDestinationState = newValue }
    }
    
    /// Selected map points from map service
    public var selectedMapPoints: TripMapMarkers {
        mapService.selectedMapPoints
    }

    ///
    public var canGetDirections: Bool {
        originCoordinate != nil && destinationCoordinate != nil
    }

    // MARK: - View Bindings
    
    public var isStepsViewPresentedBinding: Binding<Bool> {
        Binding(
            get: { self.isStepsViewPresented },
            set: { self.isStepsViewPresented = $0 }
        )
    }
    
    public var isPlanResponsePresentedBinding: Binding<Bool> {
        Binding(
            get: { self.planResponse != nil && self.isStepsViewPresented == false },
            set: { _ in }
        )
    }
    
    public var isOriginDestinationSheetPresentedBinding: Binding<Bool> {
        Binding(
            get: { self.isOriginDestinationSheetPresented },
            set: { self.isOriginDestinationSheetPresented = $0 }
        )
    }
    
    public var currentCameraPositionBinding: Binding<MapCameraPosition> {
        Binding(
            get: { self.currentCameraPosition },
            set: { self.currentCameraPosition = $0 }
        )
    }
    
    // MARK: - Initialization
    
    /// Initializes a new instance of TripPlannerCoordinatorService
    /// - Parameters:
    ///   - locationService: The location service for handling location-related functionality
    ///   - mapService: The map service for handling map-related functionality
    ///   - tripPlannerService: The trip planner service for handling API calls
    public init(
        locationService: LocationServiceProtocol,
        mapService: MapServiceProtocol,
        tripPlannerService: TripPlannerServiceProtocol
    ) {
        self.locationService = locationService
        self.mapService = mapService
        self.tripPlannerService = tripPlannerService
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Initiates location authorization request
    public func checkLocationAuthorization() {
        locationService.checkLocationAuthorization()
    }
    
    /// Updates search query with debouncing
    /// - Parameter queryFragment: The search term
    public func updateQuery(queryFragment: String) {
        locationService.updateQuery(queryFragment: queryFragment)
    }
    
    /// Appends a marker for the given location
    /// - Parameter location: The location to add a marker for
    public func appendMarker(location: Location) {
        mapService.appendMarker(location: location)
    }
    
    /// Adds origin or destination data based on the current state
    public func addOriginDestinationData() {
        mapService.addOriginDestinationData()
    }
    
    /// Removes origin or destination data based on the current state
    public func removeOriginDestinationData() {
        mapService.removeOriginDestinationData()
    }
    
    /// Selects and refreshes the coordinate based on the current origin/destination state
    public func selectAndRefreshCoordinate() {
        mapService.selectAndRefreshCoordinate()
    }
    
    /// Toggles the map marking mode
    /// - Parameter isMapMarking: Boolean indicating whether map marking is enabled
    public func toggleMapMarkingMode(_ isMapMarking: Bool) {
        isMapMarkingMode = isMapMarking
    }
    
    /// Changes the map camera to focus on the given map item
    /// - Parameter item: The map item to focus on
    public func changeMapCamera(_ item: MKMapItem) {
        currentCameraPosition = MapCameraPosition.item(item)
    }
    
    /// Changes the map camera to focus on the given coordinate
    /// - Parameter coordinate: The coordinate to focus on
    public func changeMapCamera(to coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        currentCameraPosition = .region(region)
    }
    
    /// Generates markers for the map based on selected points
    /// - Returns: MapContent containing the markers
    @MainActor
    public func generateMarkers() -> some MapContent {
        ForEach(selectedMapPoints.allMarkers, id: \.id) { markerItem in
            Marker(item: markerItem.item)
        }
    }
    
    /// Generates a map polyline based on the selected itinerary
    /// - Returns: MapPolyline object or nil if no valid itinerary is selected
    public func generateMapPolyline() -> MapPolyline? {
        guard let itinerary = selectedItinerary else { return nil }
        return mapService.generateMapPolyline(for: itinerary)
    }
    
    /// Adjusts the camera to show both origin and destination
    public func adjustOriginDestinationCamera() {
        guard let originCoordinate, let destinationCoordinate else { return }
        // Create a rectangle that encompasses both coordinates
        let minLat = min(originCoordinate.latitude, destinationCoordinate.latitude)
        let maxLat = max(originCoordinate.latitude, destinationCoordinate.latitude)
        let minLon = min(originCoordinate.longitude, destinationCoordinate.longitude)
        let maxLon = max(originCoordinate.longitude, destinationCoordinate.longitude)
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5,
                                    longitudeDelta: (maxLon - minLon) * 1.5)
        
        let region = MKCoordinateRegion(center: center, span: span)
        
        currentCameraPosition = .region(region)
    }
    
    /// Fetches trip plan
    public func fetchTrip() {
        print("Date - \(selectedDate), Time - \(selectedTime)")
        checkAndFetchTripPlanner()
    }
    
    /// Resets all trip planner related data
    public func resetTripPlanner() {
        tripPlannerService.resetTripPlanner()
        // Reset UI states
        isFetchingResponse = false
        tripPlannerErrorMessage = nil
        selectedItinerary = nil
        isStepsViewPresented = false
        // Reset map data
        removeOriginDestinationData()
        destinationCoordinate = nil
        originCoordinate = nil
        originName = OriginDestinationState.origin.name.capitalized
        destinationName = OriginDestinationState.destination.name.capitalized
    }
    
    /// Clears the plan response (used when selecting an itinerary)
    public func clearPlanResponse() {
        tripPlannerService.resetTripPlanner()
    }
    
    /// Fetches a trip plan using the new TripPlanRequest API
    /// - Parameter request: The trip plan request
    /// - Returns: The OTP response
    /// - Throws: An error if the request fails
    public func fetchTripPlan(request: TripPlanRequest) async throws -> OTPResponse {
        return try await tripPlannerService.fetchPlan(request: request)
    }
    
    // MARK: - Private Methods
    
    /// Automatically fetch the Trip Planner if there's origin coordinate and destination coordinate
    private func checkAndFetchTripPlanner() {
        guard let originCoordinate = originCoordinate,
              let destinationCoordinate = destinationCoordinate
        else {
            return
        }
        
        let request = TripPlanRequest.fromServiceData(
            originCoordinate: originCoordinate,
            destinationCoordinate: destinationCoordinate,
            selectedDate: selectedDate,
            selectedTime: selectedTime
        )
        
        isFetchingResponse = true
        
        Task {
            do {
                let response = try await tripPlannerService.fetchPlan(request: request)
                DispatchQueue.main.async {
                    self.isFetchingResponse = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.tripPlannerErrorMessage = "Failed to fetch data: \(error.localizedDescription)"
                    self.isFetchingResponse = false
                }
            }
        }
    }
} 
