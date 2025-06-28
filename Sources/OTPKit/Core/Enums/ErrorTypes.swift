//
//  ErrorTypes.swift
//  OTPKit
//
//  Created by Manu on 2025-06-06.
//

import Foundation

/// Enum-based error handling system for type-safe error management
/// Replaces scattered string-based error messages throughout the app
public enum OTPKitError: LocalizedError {
    // Trip Planning (the main ones)
    case noRouteFound
    case tripPlanningFailed(String)
    case missingOriginOrDestination

    // Location (essential for transit app)
    case locationAccessDenied
    case locationUnavailable
    case geocodingFailed
    case invalidCoordinates

    // Network (critical for API calls)
    case networkUnavailable
    case timeout
    case apiError(String)

    // Search (for location search)
    case noSearchResults
    case emptySearchQuery

    // Data (basic save/delete for favorites)
    case saveFailed(String)
    case deleteFailed(String)
}

extension OTPKitError {
    /// User-friendly error descriptions
    public var errorDescription: String? {
        switch self {
            // Trip planning
        case .noRouteFound:
            return "No transit routes found for your trip"
        case .tripPlanningFailed(let details):
            return "Trip planning failed: \(details)"
        case .missingOriginOrDestination:
            return "Please select both origin and destination"

            // Location
        case .locationAccessDenied:
            return "Enable location access in Settings to use this feature"
        case .locationUnavailable:
            return "Current location unavailable"
        case .geocodingFailed:
            return "Unable to find location address"

            // Network
        case .networkUnavailable:
            return "Check your internet connection"
        case .timeout:
            return "Request timed out, please try again"
        case .apiError(let message):
            return "Server error: \(message)"

            // Search
        case .noSearchResults:
            return "No results found"
        case .emptySearchQuery:
            return "Enter a location to search"

            // Data
        case .saveFailed(let item):
            return "Failed to save \(item)"
        case .deleteFailed(let item):
            return "Failed to delete \(item)"
        case .invalidCoordinates:
            return "Invalid Coordinates"
        }
    }

    /// Short titles for alert dialogs
    public var title: String {
        switch self {
        case .noRouteFound, .tripPlanningFailed, .missingOriginOrDestination:
            return "No Routes Found"
        case .locationAccessDenied, .locationUnavailable, .geocodingFailed:
            return "Location Error"
        case .networkUnavailable, .timeout, .apiError:
            return "Connection Error"
        case .noSearchResults, .emptySearchQuery:
            return "Search"
        case .saveFailed, .deleteFailed:
            return "Save Error"
        case .invalidCoordinates:
            return "Invalid Coordinates"
        }
    }

    /// Whether this error is recoverable with retry
    var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .apiError:
            return true
        case .tripPlanningFailed, .noRouteFound:
            return true
        case .geocodingFailed:
            return true
        default:
            return false
        }
    }
}
