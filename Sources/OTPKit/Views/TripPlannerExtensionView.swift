//
//  TripPlannerExtensionView.swift
//  OTPKit
//
//  Created by Hilmy Veradin on 12/08/24.
//

import MapKit
import SwiftUI

/// This simplify all the process of making the Trip Planner UI
public struct TripPlannerExtensionView<MapContent: View>: View {
    @State private var directionSheetDetent: PresentationDetent = .fraction(0.2)
    @State private var viewModel: TripPlannerExtensionViewModel

    private let tripPlanner: TripPlannerCoordinatorService
    private let mapContent: () -> MapContent

    public init(
        tripPlanner: TripPlannerCoordinatorService,
        @ViewBuilder mapContent: @escaping () -> MapContent
    ) {
        self.tripPlanner = tripPlanner
        self.mapContent = mapContent
        self.viewModel = TripPlannerExtensionViewModel(tripPlanner: tripPlanner)
    }

    public var body: some View {
        ZStack {
            MapReader { proxy in
                mapContent()
                    .onTapGesture { tappedLocation in
                        viewModel.handleMapTap(proxy: proxy, tappedLocation: tappedLocation)
                    }
            }
            .sheet(isPresented: viewModel.isOriginDestinationSheetPresented) {
                OriginDestinationSheetView(tripPlanner: tripPlanner)
            }
            .sheet(isPresented: viewModel.isTripPlannerSheetPresented) {
                TripPlannerSheetView(tripPlanner: tripPlanner)
                    .presentationDetents([.medium, .large])
                    .interactiveDismissDisabled()
            }
            .sheet(
                isPresented: viewModel.isStepsViewSheetPresented,
                onDismiss: {
                    viewModel.handleStepsViewDismissal()
                }
            ) {
                DirectionSheetView(tripPlanner: tripPlanner, sheetDetent: $directionSheetDetent)
                    .presentationDetents([.fraction(0.2), .medium, .large], selection: $directionSheetDetent)
                    .interactiveDismissDisabled()
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.2)))
            }

            overlayContent
        }
        .onAppear {
            viewModel.onViewAppear()
        }
        .alert(
            viewModel.currentError?.displayMessage ?? "Error",
            isPresented: Binding(
                get: { viewModel.showErrorAlert },
                set: { _ in viewModel.clearError() }
            )
        ) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.currentError?.displayMessage ?? "")
        }
    }

    // MARK: - Overlay Content

    @ViewBuilder
    private var overlayContent: some View {
        switch viewModel.overlayContentType {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial)

        case .mapMarking:
            MapMarkingView(
                onCancel: {
                    tripPlanner.toggleMapMarkingMode(false)
                    tripPlanner.removeOriginDestinationData()
                },
                onAdd: {
                    tripPlanner.addOriginDestinationData()
                    tripPlanner.toggleMapMarkingMode(false)
                }
            )

        case .tripPlanner:
            VStack {
                Spacer()
                TripPlannerView(
                    text: viewModel.getItinerarySummary(),
                    onCancel: {
                        tripPlanner.resetTripPlanner()
                    },
                    onStart: {
                        tripPlanner.isStepsViewPresented = true
                    }
                )
            }

        case .originDestination:
            VStack {
                Spacer()
                OriginDestinationView(
                    originName: tripPlanner.originName,
                    destinationName: tripPlanner.destinationName,
                    canGetDirections: tripPlanner.canGetDirections,
                    initialDate: tripPlanner.selectedDate ?? Date(),
                    initialTime: tripPlanner.selectedTime ?? Date(),
                    onLocationTap: { locationType in
                        tripPlanner.originDestinationState = locationType
                        tripPlanner.isOriginDestinationSheetPresented = true
                    },
                    onGetDirections: {
                        tripPlanner.fetchTrip()
                    },
                    onDateTimeChange: { date, time in
                        tripPlanner.selectedDate = date
                        tripPlanner.selectedTime = time
                    }
                )
            }
        case .none:
            EmptyView()
        }
    }
}
