//
//  TripPlannerSheetView.swift
//  OTPKit
//
//  Enhanced with simplified location reselection
//

import SwiftUI

public struct TripPlannerSheetView: View {
    @Environment(OriginDestinationSheetEnvironment.self) private var sheetEnvironment
    @Environment(\.dismiss) var dismiss

    @State private var showLocationSelection = false

    private let tripPlanner: TripPlannerCoordinatorService

    // MARK: - ViewModel
    private var viewModel: TripPlannerSheetViewModel {
        TripPlannerSheetViewModel(tripPlanner: tripPlanner)
    }

    // MARK: - Initialization
    public init(tripPlanner: TripPlannerCoordinatorService) {
        self.tripPlanner = tripPlanner
    }

    // MARK: - Body
    public var body: some View {
        VStack {
            if viewModel.hasItineraries {
                itinerariesList()
            } else {
                noItinerariesView()
            }

            cancelButton()
        }
    }

    // MARK: - View Components

    private func itinerariesList() -> some View {
        List(viewModel.availableItineraries, id: \.self) { itinerary in
            Button(action: {
                viewModel.selectItinerary(itinerary)
                dismiss()
            }) {
                itineraryRow(itinerary: itinerary)
            }
            .foregroundStyle(.foreground)
        }
    }

    private func itineraryRow(itinerary: Itinerary) -> some View {
        HStack(spacing: 20) {
            itineraryInfo(itinerary: itinerary)
            previewButton(itinerary: itinerary)
        }
    }

    private func itineraryInfo(itinerary: Itinerary) -> some View {
        VStack(alignment: .leading) {
            Text(viewModel.formatDuration(itinerary))
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.foreground)

            Text(viewModel.formatStartTime(itinerary))
                .foregroundStyle(.gray)

            legsFlow(itinerary: itinerary)
        }
    }

    private func previewButton(itinerary: Itinerary) -> some View {
        Button(action: {
            viewModel.previewItinerary(itinerary)
            dismiss()
        }) {
            Image(systemName: "eye")
                .foregroundStyle(.blue)
        }
    }

    private func legsFlow(itinerary: Itinerary) -> some View {
        HStack(spacing: 4) {
            ForEach(itinerary.legs, id: \.self) { leg in
                legView(leg: leg)
            }
        }
    }

    private func legView(leg: Leg) -> some View {
        Group {
        switch viewModel.getLegViewType(for: leg) {
        case .vehicle:
            ItineraryLegVehicleView(leg: leg)
        case .walk:
            ItineraryLegWalkView(leg: leg)
        case .unknown:
            ItineraryLegUnknownView(leg: leg)
        }
    }
    }

    private func noItinerariesView() -> some View {
        VStack {
            Text(viewModel.noTripPlannerMessage)
                .foregroundStyle(.gray)
                .padding()
        }
    }

    private func cancelButton() -> some View {
        Button("Cancel") {
            viewModel.cancelTripPlanning()
            dismiss()
        }
        .padding()
    }
}

#Preview {
    let tripPlanner = TripPlannerServiceFactory.create(
        baseURL: URL(string: "https://otp.prod.sound.obaweb.org/otp/routers/default/")!
    )
    return TripPlannerSheetView(tripPlanner: tripPlanner)
}
