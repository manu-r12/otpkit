//
//  CurrentTripInfoView.swift
//  OTPKit
//
//  Created by Manu on 2025-06-26.
//

import SwiftUI

/// A reusable view that displays current origin and destination information
struct CurrentTripInfoView: View {
    let originName: String
    let destinationName: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.green)
                    .frame(width: 16)
                Text(originName)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
            }

            HStack(spacing: 12) {
                Image(systemName: "mappin")
                    .foregroundColor(.red)
                    .frame(width: 16)
                Text(destinationName)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
