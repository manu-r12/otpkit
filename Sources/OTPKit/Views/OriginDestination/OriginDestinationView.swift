//
//  OriginDestinationView.swift
//  OTPKit
//
//  Created by Hilmy Veradin on 18/07/24.
//

import SwiftUI

/// OriginDestinationView is the main view for setting up Origin/Destination in OTPKit.
/// It consists a list of Origin and Destination along with the MapKit
public struct OriginDestinationView: View {
    // Data properties
    private let originName: String
    private let destinationName: String
    private let canGetDirections: Bool
    private let initialDate: Date
    private let initialTime: Date

    // Action closures
    private let onLocationTap: (OriginDestinationState) -> Void
    private let onGetDirections: VoidBlock
    private let onDateTimeChange: (Date, Date) -> Void

    // Internal state for date/time pickers
    @State private var selectedDate: Date
    @State private var selectedTime: Date

    public init(
        originName: String,
        destinationName: String,
        canGetDirections: Bool,
        initialDate: Date = Date(),
        initialTime: Date = Date(),
        onLocationTap: @escaping (OriginDestinationState) -> Void,
        onGetDirections: @escaping VoidBlock,
        onDateTimeChange: @escaping (Date, Date) -> Void = { _, _ in }
    ) {
        self.originName = originName
        self.destinationName = destinationName
        self.canGetDirections = canGetDirections
        self.initialDate = initialDate
        self.initialTime = initialTime
        self.onLocationTap = onLocationTap
        self.onGetDirections = onGetDirections
        self.onDateTimeChange = onDateTimeChange

        // Initialize state with provided values
        self._selectedDate = State(initialValue: initialDate)
        self._selectedTime = State(initialValue: initialTime)
    }

    private func originDestinationField(icon: String, text: String, action: @escaping VoidBlock) -> some View {
        Button(action: action, label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .foregroundColor(.white)
                }

                Text(text)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)
                Spacer()
            }
            .padding(8)
            .background(Color(.secondarySystemBackground))
        })
        .foregroundStyle(.foreground)
    }

    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // Origin Button
                originDestinationField(icon: "paperplane.fill", text: originName) {
                    onLocationTap(.origin)
                }

                // Destination Button
                originDestinationField(icon: "mappin", text: destinationName) {
                    onLocationTap(.destination)
                }

                // Date/Time Selector
                DateTimeSelector(
                    selectedDate: $selectedDate,
                    selectedTime: $selectedTime,
                    onDateTimeChange: { date, time in
                        onDateTimeChange(date, time)
                    }
                )
                .background(Color(.secondarySystemBackground))

                // Get Directions Button
                if canGetDirections {
                    GetDirectionsButton(action: onGetDirections)
                }
            }
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 6)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}
