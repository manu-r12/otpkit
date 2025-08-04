import Foundation

/// A type that can provide trip planning capabilities.
public protocol TripPlannerProvider {
    /// Fetches a trip plan from the provider.
    /// - Parameters:
    ///   - fromPlace: The starting location of the trip.
    ///   - toPlace: The destination of the trip.
    ///   - time: The time of the trip.
    ///   - date: The date of the trip.
    ///   - mode: The transportation mode(s) for the trip.
    ///   - arriveBy: Whether the trip should arrive by the specified time.
    ///   - maxWalkDistance: The maximum walking distance in meters.
    ///   - wheelchair: Whether the trip should be wheelchair accessible.
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
}
