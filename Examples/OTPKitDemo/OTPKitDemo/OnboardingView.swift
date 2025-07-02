import SwiftUI
import OTPKit
import MapKit

/// View to select region for demo purposes
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Binding var selectedRegionURL: URL?
    @Binding var tripPlannerService: TripPlannerCoordinatorService?
    @State private var selectedRegion: String = "Puget Sound"

    private let regions = [
        "Puget Sound": [
            "url": URL(string: "https://otp.prod.sound.obaweb.org/otp/routers/default/")!,
            "center": CLLocationCoordinate2D(latitude: 47.64585, longitude: -122.2963)
        ],
        "San Diego": [
            "url": URL(string: "https://realtime.sdmts.com:9091/otp/routers/default/")!,
            "center": CLLocationCoordinate2D(latitude: 32.731591, longitude: -117.1896335)
        ],
        "Tampa": [
            "url": URL(string: "https://otp.prod.obahart.org/otp/routers/default/")!,
            "center": CLLocationCoordinate2D(latitude: 27.9769105, longitude: -82.445851)
        ]
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Your Region")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)

            Text("Choose the transit system you'd like to use for trip planning")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 15) {
                ForEach(Array(regions.keys.sorted()), id: \.self) { region in
                    Button(action: {
                        selectedRegion = region
                    }) {
                        HStack {
                            Text(region)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedRegion == region {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedRegion == region ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedRegion == region ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)

            Spacer()

            Button("Continue") {
                let selection = regions[selectedRegion]!

                // swiftlint:disable force_cast
                let url = selection["url"] as! URL
                let center = selection["center"] as! CLLocationCoordinate2D
                // swiftlint:enable force_cast

                selectedRegionURL = url

                tripPlannerService = TripPlannerServiceFactory.create(baseURL: url)

                tripPlannerService?.changeMapCamera(to: center)
                hasCompletedOnboarding = true

            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    let planner = TripPlannerServiceFactory.create(
        baseURL: URL(string: "https://otp.prod.sound.obaweb.org/otp/routers/default/")!
    )

    return OnboardingView(
        hasCompletedOnboarding: .constant(true),
        selectedRegionURL: .constant(nil),
        tripPlannerService: .constant(planner)
    )
}
