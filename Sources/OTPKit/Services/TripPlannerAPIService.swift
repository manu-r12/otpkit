//
//  TripPlannerAPIService.swift
//  OTPKit
//
//  Created by Manu on 2025-01-27.
//

import Foundation

/// Concrete implementation of TripPlannerServiceProtocol
public final class TripPlannerAPIService: TripPlannerServiceProtocol {
    
    // MARK: - Properties
    
    private let apiClient: RestAPI
    
    // MARK: - Published Properties
    
    public private(set) var planResponse: OTPResponse?
    
    // MARK: - Initialization
    
    /// Initializes a new instance of TripPlannerAPIService
    /// - Parameter apiClient: The REST API client for making network requests
    public init(apiClient: RestAPI) {
        self.apiClient = apiClient
    }
    
    // MARK: - TripPlannerServiceProtocol
    
    public func fetchPlan(request: TripPlanRequest) async throws -> OTPResponse {
        // Validate the request
        guard request.isValid() else {
            throw URLError(.badURL)
        }
        
        // Format coordinates for API
        let fromPlace = "\(request.origin.latitude),\(request.origin.longitude)"
        let toPlace = "\(request.destination.latitude),\(request.destination.longitude)"
        
        // Format date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.string(from: request.date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: request.time)
        
        let response = try await apiClient.fetchPlan(
            fromPlace: fromPlace,
            toPlace: toPlace,
            time: timeString,
            date: dateString,
            mode: request.transportModesString,
            arriveBy: request.arriveBy,
            maxWalkDistance: request.maxWalkDistance,
            wheelchair: request.wheelchairAccessible
        )
        
        // Update the stored response
        planResponse = response
        return response
    }
    
    public func fetchPlan(
        fromPlace: String,
        toPlace: String,
        time: String,
        date: String,
        mode: String,
        arriveBy: Bool,
        maxWalkDistance: Int,
        wheelchair: Bool
    ) async throws -> OTPResponse {
        let response = try await apiClient.fetchPlan(
            fromPlace: fromPlace,
            toPlace: toPlace,
            time: time,
            date: date,
            mode: mode,
            arriveBy: arriveBy,
            maxWalkDistance: maxWalkDistance,
            wheelchair: wheelchair
        )
        
        // Update the stored response
        planResponse = response
        return response
    }
    
    public func resetTripPlanner() {
        planResponse = nil
    }
    
    public func getFormattedTodayDate() -> String {
        Date.currentFormattedDate
    }
    
    public func getCurrentTimeFormatted() -> String {
        Date.currentFormattedTime
    }
} 