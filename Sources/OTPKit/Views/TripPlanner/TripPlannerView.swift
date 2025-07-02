//
//  TripPlannerView.swift
//  OTPKit
//
//  Created by Hilmy Veradin on 30/07/24.
//

import SwiftUI

public struct TripPlannerView: View {
    private let text: String
    private let onCancel: VoidBlock
    private let onStart: VoidBlock

    public init(
        text: String,
        onCancel: @escaping VoidBlock,
        onStart: @escaping VoidBlock
    ) {
        self.text = text
        self.onCancel = onCancel
        self.onStart = onStart
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .fontWeight(.semibold)
                .padding(16)
            HStack {
                Button(action: {
                    onCancel()
                }, label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(BorderedButtonStyle())

                Button(action: {
                    onStart()
                }, label: {
                    Text("Start")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .padding()
        }
        .background(.thickMaterial)
    }
}

#Preview {
    TripPlannerView(
        text: "43 minutes, departs at 4:15 PM",
        onCancel: {
            print("Cancel tapped")
        },
        onStart: {
            print("Start tapped")
        }
    )
}
