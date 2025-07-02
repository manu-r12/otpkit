//
//  MapView.swift
//  OTPKitDemo
//
//  Created by Hilmy Veradin on 25/06/24.
//

import MapKit
import OTPKit
import SwiftUI

struct MapView: View {
    private let tripPlanner: TripPlannerCoordinatorService

    init(tripPlanner: TripPlannerCoordinatorService) {
        self.tripPlanner = tripPlanner
    }

    var body: some View {
        ZStack {
            TripPlannerExtensionView(tripPlanner: tripPlanner) {
                Map(position: tripPlanner.currentCameraPositionBinding, interactionModes: .all) {
                    tripPlanner.generateMarkers()
                    tripPlanner.generateMapPolyline()
                        .stroke(.blue, lineWidth: 5)
                }
                .animation(
                    .easeIn(duration: 0.01),
                    value: tripPlanner.currentCameraPositionBinding.wrappedValue
                )
                .mapControls {
                    if !tripPlanner.isMapMarkingMode {
                        MapUserLocationButton()
                        MapPitchToggle()
                    }
                }
            }
        }
    }
}

#Preview {
    let tripPlanner = TripPlannerServiceFactory.create(
        baseURL: URL(string: "https://otp.prod.sound.obaweb.org/otp/routers/default/")!
    )
    return MapView(tripPlanner: tripPlanner)
}
