//
//  TripPlannerServiceProtocol.swift
//  OTPKit
//
//  Created by Manu on 2025-01-27.
//

import Foundation

/// Protocol for trip planning services
public protocol TripPlannerServiceProtocol: AnyObject {
    
    /// Current plan response from the API
    var planResponse: OTPResponse? { get }
    
        /// Fetches trip plan from the API using a TripPlanRequest
    /// - Parameter request: The trip plan request containing all necessary parameters
    /// - Returns: An OTPResponse object containing the trip plan
    /// - Throws: An error if the network request fails or the response is invalid
    func fetchPlan(request: TripPlanRequest) async throws -> OTPResponse
    
    /// Fetches trip plan from the API (legacy method for backward compatibility)
    /// - Parameters:
    ///   - fromPlace: The starting location of the trip
    ///   - toPlace: The destination of the trip
    ///   - time: The time of the trip
    ///   - date: The date of the trip
    ///   - mode: The transportation mode(s) for the trip
    ///   - arriveBy: Whether the trip should arrive by the specified time
    ///   - maxWalkDistance: The maximum walking distance in meters
    ///   - wheelchair: Whether the trip should be wheelchair accessible
    /// - Returns: An OTPResponse object containing the trip plan
    /// - Throws: An error if the network request fails or the response is invalid
    func fetchPlan(
        fromPlace: String,
        toPlace: String,
        time: String,
        date: String,
        mode: String,
        arriveBy: Bool,
        maxWalkDistance: Int,
        wheelchair: Bool
    ) async throws -> OTPResponse
    
    /// Resets all trip planner related data
    func resetTripPlanner()
    
    /// Gets the current date formatted as a string
    /// - Returns: The formatted date string
    func getFormattedTodayDate() -> String
    
    /// Gets the current time formatted as a string
    /// - Returns: The formatted time string
    func getCurrentTimeFormatted() -> String
} 