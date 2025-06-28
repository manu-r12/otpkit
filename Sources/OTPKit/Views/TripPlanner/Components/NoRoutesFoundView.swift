//
//  NoRoutesFoundView.swift
//  OTPKit
//
//  Created by Manu on 2025-06-26.
//


import SwiftUI

/// A reusable view that displays when no transit routes are found
/// Shows current trip information and provides action to change locations
struct NoRoutesFoundView: View {
    let originName: String
    let destinationName: String
    let onChangeLocations: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                    .foregroundColor(.secondary)
                    .padding(.top, 15)
                    .padding(.bottom, 8)

                Text("No Routes Found")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Try selecting different locations")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity)

            // Current trip info
            CurrentTripInfoView(
                originName: originName,
                destinationName: destinationName
            )

            Button(action: onChangeLocations) {
                Text("Change Locations")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .padding(.horizontal)

            Spacer()
        }
    }
}


#Preview {
    VStack {
        NoRoutesFoundView(
            originName: "Seattle Center",
            destinationName: "Pike Place Market"
        ) {
            print("Change locations tapped")
        }

        Divider()
            .padding()

        CurrentTripInfoView(
            originName: "Current Location",
            destinationName: "Space Needle"
        )
    }
}
