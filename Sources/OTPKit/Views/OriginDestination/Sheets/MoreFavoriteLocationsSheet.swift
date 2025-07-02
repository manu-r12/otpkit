//
//  MoreFavoriteLocationsSheet.swift
//  OTPKit
//
//  Created by Hilmy Veradin on 18/07/24.
//

import SwiftUI

/// Show all the lists of favorite locations
public struct MoreFavoriteLocationsSheet: View {
    private let tripPlanner: TripPlannerCoordinatorService

    public init(tripPlanner: TripPlannerCoordinatorService) {
        self.tripPlanner = tripPlanner
    }

    public var body: some View {
        NavigationView {
        VStack {
                Text("More Favorite Locations")
                    .font(.title)
            .padding()
                Spacer()
            }
        }
    }
}

#Preview {
    let tripPlanner = TripPlannerServiceFactory.create(
        baseURL: URL(string: "https://otp.prod.sound.obaweb.org/otp/routers/default/")!
    )
    return MoreFavoriteLocationsSheet(tripPlanner: tripPlanner)
}
