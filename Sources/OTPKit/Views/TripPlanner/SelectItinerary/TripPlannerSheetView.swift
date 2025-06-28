//
//  TripPlannerSheetView.swift
//  OTPKit
//
//  Enhanced with simplified location reselection
//

import SwiftUI

public struct TripPlannerSheetView: View {
    @Environment(TripPlannerService.self) private var tripPlanner
    @Environment(OriginDestinationSheetEnvironment.self) private var sheetEnvironment
    @Environment(\.dismiss) var dismiss

    @State private var showLocationSelection = false

    // MARK: - ViewModel
    private var viewModel: TripPlannerSheetViewModel {
        TripPlannerSheetViewModel(tripPlannerService: tripPlanner)
    }

    // MARK: - Initialization
    public init() {}

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

    private func legsFlow(itinerary: Itinerary) -> some View {
        FlowLayout {
            ForEach(Array(zip(itinerary.legs.indices, itinerary.legs)), id: \.1) { index, leg in
                legView(for: leg)

                if index < itinerary.legs.count - 1 {
                    VStack {
                        Image(systemName: "chevron.right.circle.fill")
                            .frame(width: 8, height: 16)
                    }
                    .frame(height: 40)
                }
            }
        }
    }

    @ViewBuilder
    private func legView(for leg: Leg) -> some View {
        switch viewModel.getLegViewType(for: leg) {
        case .vehicle:
            ItineraryLegVehicleView(leg: leg)
        case .walk:
            ItineraryLegWalkView(leg: leg)
        case .unknown:
            ItineraryLegUnknownView(leg: leg)
        }
    }

    private func previewButton(itinerary: Itinerary) -> some View {
        Button(action: {
            viewModel.previewItinerary(itinerary)
            dismiss()
        }) {
            Text("Preview")
                .padding(30)
                .background(Color.green)
                .foregroundStyle(.foreground)
                .fontWeight(.bold)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // REFACTORED: Using the new NoRoutesFoundView
    private func noItinerariesView() -> some View {
        NoRoutesFoundView(
            originName: tripPlanner.originName,
            destinationName: tripPlanner.destinationName
        ) {
            // Dismiss the entire TripPlannerSheetView
            dismiss()
            // Reset trip planner to show OriginDestinationView in parent
            tripPlanner.resetTripPlanner()
        }
    }

    private func cancelButton() -> some View {
        Button(action: {
            viewModel.cancelTripPlanning()
            dismiss()
        }) {
            Text("Cancel")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .foregroundStyle(.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
        }
    }
}

#Preview {
    TripPlannerSheetView()
}
