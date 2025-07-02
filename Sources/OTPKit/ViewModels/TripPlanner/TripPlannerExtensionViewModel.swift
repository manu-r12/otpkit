//
//  TripPlannerExtensionViewModel.swift
//  OTPKit
//
//  Created by Manu on 2025-06-14.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

/// ViewModel for TripPlannerExtensionView
/// Coordinates map interactions, overlays, and sheet presentations
@Observable
final class TripPlannerExtensionViewModel: BaseViewModel {

    // MARK: - Dependencies
    private let tripPlanner: TripPlannerCoordinatorService

    // MARK: - Computed Properties

    /// Whether the trip planner is currently fetching a response
    var isFetchingResponse: Bool {
        tripPlanner.isFetchingResponse
    }

    /// Whether map marking mode is active
    var isMapMarkingMode: Bool {
        tripPlanner.isMapMarkingMode
    }

    /// Whether steps view is presented
    var isStepsViewPresented: Bool {
        tripPlanner.isStepsViewPresented
    }

    /// Current selected itinerary
    var selectedItinerary: Itinerary? {
        tripPlanner.selectedItinerary
    }

    /// Current plan response
    var planResponse: OTPResponse? {
        tripPlanner.planResponse
    }

    /// Binding for origin/destination sheet presentation
    var isOriginDestinationSheetPresented: Binding<Bool> {
        tripPlanner.isOriginDestinationSheetPresentedBinding
    }

    /// Binding for trip planner sheet presentation
    var isTripPlannerSheetPresented: Binding<Bool> {
        tripPlanner.isPlanResponsePresentedBinding
    }

    /// Binding for steps view presentation
    var isStepsViewSheetPresented: Binding<Bool> {
        tripPlanner.isStepsViewPresentedBinding
    }

    // MARK: - Overlay State

    /// Determines what overlay content should be shown
    var overlayContentType: OverlayContentType {
        if isFetchingResponse {
            return .loading
        } else if isMapMarkingMode {
            return .mapMarking
        } else if let _ = selectedItinerary, !isStepsViewPresented {
            return .tripPlanner
        } else if planResponse == nil {
            return .originDestination
        } else {
            return .none
        }
    }

    // MARK: - Initialization

    init(tripPlanner: TripPlannerCoordinatorService) {
        self.tripPlanner = tripPlanner
        super.init()
    }

    // MARK: - Public Methods

    /// Called when view appears - checks location authorization
    func onViewAppear() {
        tripPlanner.checkLocationAuthorization()
    }

    /// Handles map tap gesture for location marking
    func handleMapTap(proxy: MapProxy, tappedLocation: CGPoint) {
        guard isMapMarkingMode else { return }

        guard let coordinate = proxy.convert(tappedLocation, from: .local) else {
            handleError(OTPKitError.invalidCoordinates)
            return
        }

        executeTask {
            await self.processMapTap(coordinate: coordinate)
        }
    }

    /// Handles steps view dismissal
    func handleStepsViewDismissal() {
        tripPlanner.resetTripPlanner()
    }

    /// Gets summary text for selected itinerary
    func getItinerarySummary() -> String {
        selectedItinerary?.summary ?? ""
    }

    // MARK: - Private Methods

    /// Processes map tap coordinate and creates location
    private func processMapTap(coordinate: CLLocationCoordinate2D) async {
        let mapItem = MKMapItem(placemark: .init(coordinate: coordinate))
        let locationTitle = mapItem.name ?? "Location unknown"
        let locationSubtitle = mapItem.placemark.title ?? "Location unknown"

        let location = Location(
            title: locationTitle,
            subTitle: locationSubtitle,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        await MainActor.run {
            tripPlanner.appendMarker(location: location)
        }
    }
}

