//
//  GetDirectionsButton.swift
//  OTPKit
//
//  Created by Manu on 2025-03-30.
//

import SwiftUI

public struct GetDirectionsButton: View {
    let action: VoidBlock

    public init(action: @escaping VoidBlock) {
        self.action = action
    }

    public var body: some View {
        VStack {
            Button(action: {
                action()
            }) {
                HStack {
                    Image(systemName: "location.fill")
                        .font(.title3)
                    Text("Get Directions")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.green)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 12)
    }
}
