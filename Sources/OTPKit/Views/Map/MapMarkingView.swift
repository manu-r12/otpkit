//
//  MapMarkingView.swift
//  OTPKit
//
//  Created by Hilmy Veradin on 30/07/24.
//

import SwiftUI

/// View for Map Marking Mode
/// User able to add Marking directly from the map
public struct MapMarkingView: View {
    private let onCancel: VoidBlock
    private let onAdd: VoidBlock

    public init(
        onCancel: @escaping VoidBlock,
        onAdd: @escaping VoidBlock
    ) {
        self.onCancel = onCancel
        self.onAdd = onAdd
    }

    public var body: some View {
        VStack {
            Spacer()

            Text("Tap on the map to add a pin.")
                .padding(16)
                .background(.regularMaterial)
                .cornerRadius(16)

            HStack(spacing: 16) {
                Button(action: {
                    onCancel()
                }, label: {
                    Text("Cancel")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(BorderedButtonStyle())

                Button(action: {
                    onAdd()
                }, label: {
                    Text("Add")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .frame(maxWidth: .infinity)
            .padding(16)
        }
        .padding(.bottom, 24)
    }
}

#Preview {
    MapMarkingView(
        onCancel: {
            print("Cancel tapped")
        },
        onAdd: {
            print("Add tapped")
        }
    )
}
