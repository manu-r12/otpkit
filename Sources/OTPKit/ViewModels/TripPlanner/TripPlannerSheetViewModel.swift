//
//  TripPlannerSheetViewModel.swift
//  OTPKit
//
//  Created by Manu on 2025-06-06.
//

import Foundation
import SwiftUI

/// ViewModel for TripPlannerSheetView
/// Handles itinerary selection and trip planning logic
/// Note: This view only displays results, doesn't handle API calls or errors
@Observable
final class TripPlannerSheetViewModel {

    // MARK: - Dependencies
    private let tripPlanner: TripPlannerCoordinatorService

    // MARK: - Published Properties

    /// Available itineraries from the plan response
    var availableItineraries: [Itinerary] {
        tripPlanner.planResponse?.plan?.itineraries ?? []
    }

    /// Whether there are itineraries to display
    var hasItineraries: Bool {
        !availableItineraries.isEmpty
    }

    /// Message when no trip planner data is available
    var noTripPlannerMessage: String {
        "Can't find trip planner. Please try another pin point"
    }

    // MARK: - Initialization

    init(tripPlanner: TripPlannerCoordinatorService) {
        self.tripPlanner = tripPlanner
    }

    // MARK: - Public Methods

    /// Selects an itinerary and dismisses the sheet
    func selectItinerary(_ itinerary: Itinerary) {
        tripPlanner.selectedItinerary = itinerary
        tripPlanner.clearPlanResponse()
    }

    /// Selects an itinerary, adjusts camera, and dismisses sheet
    func previewItinerary(_ itinerary: Itinerary) {
        tripPlanner.selectedItinerary = itinerary
        tripPlanner.clearPlanResponse()
        tripPlanner.adjustOriginDestinationCamera()
    }

    /// Cancels trip planning and resets all data
    func cancelTripPlanning() {
        tripPlanner.resetTripPlanner()
    }

    /// Generates appropriate leg view type based on transportation mode
    func getLegViewType(for leg: Leg) -> TripLegViewType {
        switch leg.mode {
        case "BUS", "TRAM":
            return .vehicle
        case "WALK":
            return .walk
        default:
            return .unknown
        }
    }

    /// Formats itinerary start time for display
    func formatStartTime(_ itinerary: Itinerary) -> String {
        "Bus scheduled at \(Formatters.formatDateToTime(itinerary.startTime))"
    }

    /// Formats itinerary duration for display
    func formatDuration(_ itinerary: Itinerary) -> String {
        Formatters.formatTimeDuration(itinerary.duration)
    }
}

