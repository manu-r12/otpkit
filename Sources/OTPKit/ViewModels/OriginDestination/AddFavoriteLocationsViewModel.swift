//
//  AddFavoriteLocationsViewModel.swift
//  OTPKit
//
//  Created by Hilmy Veradin on 18/07/24.
//

import Foundation
import CoreLocation

/// ViewModel for AddFavoriteLocationsSheet
/// Handles search, filtering, and favorite location management
@Observable
public final class AddFavoriteLocationsViewModel: BaseViewModel {

    // MARK: - Dependencies
    private let tripPlannerService: TripPlannerCoordinatorService
    private let sheetEnvironment: OriginDestinationSheetEnvironment
    private let userDefaultsService: UserDefaultsServices

    // MARK: - Published Properties

    /// Current search text
    public var searchText = ""

    /// Search focus state
    public var isSearchFocused = false

    /// Search completions from the trip planner service
    public var completions: [Location] {
        tripPlannerService.completions
    }

    /// Favorite locations
    public var favoriteLocations: [Location] {
        switch userDefaultsService.getFavoriteLocationsData() {
        case .success(let locations):
            return locations
        case .failure:
            return []
        }
    }

    /// Recent locations
    public var recentLocations: [Location] {
        switch userDefaultsService.getRecentLocations() {
        case .success(let locations):
            return locations
        case .failure:
            return []
        }
    }

    /// Current user location
    public var currentLocation: Location? {
        tripPlannerService.currentLocation
    }

    /// Is all recent presented
    public var isAllRecentPresented = false

    // MARK: - Computed Properties

    /// Filtered completions (excludes favorites)
    var filteredCompletions: [Location] {
        let favorites = favoriteLocations
        return completions.filter { completion in
            !favorites.contains { favorite in
                favorite.title == completion.title &&
                favorite.subTitle == completion.subTitle &&
                favorite.latitude == completion.latitude &&
                favorite.longitude == completion.longitude
            }
        }
    }

    /// Recent locations filtered to exclude existing favorites
    var filteredRecentLocations: [Location] {
        let favorites = favoriteLocations
        return recentLocations.filter { recent in
            !favorites.contains { favorite in
                favorite.title == recent.title &&
                favorite.subTitle == recent.subTitle &&
                favorite.latitude == recent.latitude &&
                favorite.longitude == recent.longitude
            }
        }
    }

    /// Recent locations limited to 5 items
    var limitedRecentLocations: [Location] {
        Array(filteredRecentLocations.prefix(5))
    }

    /// Check if current location is already in favorites
    var isCurrentLocationFavorite: Bool {
        guard let currentLocation = currentLocation else { return false }
        return favoriteLocations.contains { favorite in
            favorite.title == currentLocation.title &&
            favorite.subTitle == currentLocation.subTitle &&
            favorite.latitude == currentLocation.latitude &&
            favorite.longitude == currentLocation.longitude
        }
    }

    /// Should show current user section
    var shouldShowCurrentUserSection: Bool {
        searchText.isEmpty && currentLocation != nil && !isCurrentLocationFavorite
    }

    /// Should show recent locations section
    var shouldShowRecentLocationsSection: Bool {
        searchText.isEmpty && !isSearchFocused && !filteredRecentLocations.isEmpty
    }

    /// Should show search results
    var shouldShowSearchResults: Bool {
        !searchText.isEmpty
    }

    /// Should show no results for search
    var shouldShowNoSearchResults: Bool {
        shouldShowSearchResults && filteredCompletions.isEmpty
    }

    /// Should show no recent locations message
    var shouldShowNoRecentLocations: Bool {
        searchText.isEmpty && !isSearchFocused && filteredRecentLocations.isEmpty
    }

    // MARK: - Initialization

    public init(
        tripPlannerService: TripPlannerCoordinatorService,
         sheetEnvironment: OriginDestinationSheetEnvironment,
        userDefaultsService: UserDefaultsServices
    ) {
        self.tripPlannerService = tripPlannerService
        self.sheetEnvironment = sheetEnvironment
        self.userDefaultsService = userDefaultsService
        super.init()
    }

    // MARK: - Public Methods

    /// Updates search query and triggers completion search
    public func updateSearchQuery(_ query: String) {
        searchText = query
        tripPlannerService.updateQuery(queryFragment: query)
    }

    /// Adds location to favorites
    public func addToFavorites(_ location: Location) {
        _ = userDefaultsService.saveFavoriteLocationData(data: location)
    }

    /// Adds current user location to favorites
    public func addCurrentUserLocationToFavorites() {
        guard let location = currentLocation else { return }
        addToFavorites(location)
    }

    /// Refreshes data when view appears
    public func onViewAppear() {
        // Any setup needed when view appears
    }

    public func selectCurrentUserLocation() {
        guard let location = currentLocation else { return }
        selectLocation(location)
    }

    public func selectLocationOnMap() {
        tripPlannerService.toggleMapMarkingMode(true)
    }

    public func selectLocation(_ location: Location) {
        switch tripPlannerService.originDestinationState {
        case .origin:
            tripPlannerService.originName = location.title
            tripPlannerService.originCoordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
        case .destination:
            tripPlannerService.destinationName = location.title
            tripPlannerService.destinationCoordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
        }
        
        _ = userDefaultsService.saveRecentLocations(data: location)
    }

    public override func clearError() {
        currentError = nil
        showErrorAlert = false
    }
}
