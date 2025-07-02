//
//  OriginDestinationSheetViewModel.swift
//  OTPKit
//
//  Created by Hilmy Veradin on 18/07/24.
//

import Foundation
import CoreLocation

/// ViewModel for OriginDestinationSheetView
/// Handles search, location selection, favorites, and recent locations logic
@Observable
public final class OriginDestinationSheetViewModel: BaseViewModel {

    // MARK: - Dependencies
    private let tripPlannerService: TripPlannerCoordinatorService
    private let sheetEnvironment: OriginDestinationSheetEnvironment
    private let userDefaultsService: UserDefaultsServices

    // MARK: - Published Properties

    /// Current search text
    public var searchText = ""

    /// Search focus state
    public var isSearchFocused = false

    /// Current location type being selected
    public var currentState: OriginDestinationState {
        tripPlannerService.originDestinationState == .origin ? .origin : .destination
    }

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

    /// Page title based on current selection type
    public var pageTitle: String {
        switch currentState {
        case .origin:
            return "Select Origin"
        case .destination:
            return "Select Destination"
        }
    }

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

    /// Recent locations limited to 5 items
    var limitedRecentLocations: [Location] {
        Array(recentLocations.prefix(5))
    }

    /// Should show current user section
    var shouldShowCurrentUserSection: Bool {
        searchText.isEmpty && isSearchFocused && currentLocation != nil
    }

    /// Should show location selection section
    var shouldShowLocationSelectionSection: Bool {
        searchText.isEmpty && !isSearchFocused
    }

    /// Should show favorites section
    var shouldShowFavoritesSection: Bool {
        searchText.isEmpty && !isSearchFocused
    }

    /// Should show recents section
    var shouldShowRecentsSection: Bool {
        searchText.isEmpty && !isSearchFocused && !recentLocations.isEmpty
    }

    /// Should show search results
    var shouldShowSearchResults: Bool {
        !searchText.isEmpty
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
        tripPlannerService.updateQuery(queryFragment: query)
    }

    /// Handles location selection and updates trip planner
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
        
        // Dismiss the main origin destination sheet
        dismissMainSheet()
    }

    /// Selects current user location
    public func selectCurrentUserLocation() {
        guard let location = currentLocation else { return }
        selectLocation(location)
    }

    /// Triggers map marking mode
    public func selectLocationOnMap() {
        tripPlannerService.toggleMapMarkingMode(true)
        dismissMainSheet()
    }

    /// Adds location to favorites
    public func addToFavorites(_ location: Location) {
        executeTask {
            switch self.userDefaultsService.saveFavoriteLocationData(data: location) {
            case .success:
                await MainActor.run {
                    self.sheetEnvironment.refreshFavoriteLocations()
                }
            case .failure(let error):
                throw OTPKitError.saveFailed("favorite location: \(error.localizedDescription)")
            }
        }
    }

    /// Removes location from favorites
    public func removeFromFavorites(_ location: Location) {
        _ = userDefaultsService.deleteFavoriteLocationData(with: location.id)
    }

    /// Refreshes data when view appears
    public func onViewAppear() {
        sheetEnvironment.refreshFavoriteLocations()
        sheetEnvironment.refreshRecentLocations()
    }

    /// Clears current error
    public override func clearError() {
        currentError = nil
        showErrorAlert = false
    }

    // MARK: - Private Methods

    private func mockSelection(_ location: Location) {
        // connect it with mock
    }

    /// Dismisses the main origin destination sheet
    private func dismissMainSheet() {
        tripPlannerService.isOriginDestinationSheetPresented = false
    }
}
