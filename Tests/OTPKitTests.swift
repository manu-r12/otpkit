/*
 * Copyright (C) Open Transit Software Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// swiftlint:disable force_cast line_length

@testable import OTPKit
import XCTest
import CoreLocation

class OTPKitTests: OTPTestCase {
    let soundTransitBaseURL = URL(string: "https://otp.prod.sound.obaweb.org/otp/routers/default/")!

    func testPlanBasics() async throws {
        let restApi = buildRestAPIClient()

        let dataLoader = restApi.dataLoader as! MockDataLoader

        dataLoader.mock(URLString: "https://otp.prod.sound.obaweb.org/otp/routers/default/plan?fromPlace=47.6097,-122.3331&toPlace=47.6154,-122.3208&time=8:00%20AM&date=05-10-2024&mode=TRANSIT,WALK&arriveBy=false&maxWalkDistance=800&wheelchair=false", with: Fixtures.loadData(file: "plan_basic_case.json"))

        let result = try await restApi.fetchPlan(
            fromPlace: "47.6097,-122.3331",
            toPlace: "47.6154,-122.3208",
            time: "8:00 AM",
            date: "05-10-2024",
            mode: "TRANSIT,WALK",
            arriveBy: false,
            maxWalkDistance: 800,
            wheelchair: false
        )

        XCTAssertNotNil(result)

        let plan = result.plan!

        XCTAssertNotNil(plan)

        XCTAssertEqual(plan.itineraries.count, 3)

        let itinerary = plan.itineraries.first

        XCTAssertEqual(itinerary?.duration, 595)
    }

    func testTripPlanRequestCreation() throws {
        let origin = CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321)
        let destination = CLLocationCoordinate2D(latitude: 47.6205, longitude: -122.3493)
        let date = Date()
        let time = Date()
        
        let request = TripPlanRequest(
            origin: origin,
            destination: destination,
            date: date,
            time: time,
            transportModes: [.transit, .walk],
            maxWalkDistance: 1000,
            wheelchairAccessible: false,
            arriveBy: false
        )
        
        XCTAssertEqual(request.origin.latitude, 47.6062)
        XCTAssertEqual(request.origin.longitude, -122.3321)
        XCTAssertEqual(request.destination.latitude, 47.6205)
        XCTAssertEqual(request.destination.longitude, -122.3493)
        XCTAssertEqual(request.transportModes, [.transit, .walk])
        XCTAssertEqual(request.maxWalkDistance, 1000)
        XCTAssertFalse(request.wheelchairAccessible)
        XCTAssertFalse(request.arriveBy)
        XCTAssertTrue(request.isValid())
    }
    
    func testTripPlanRequestValidation() throws {
        let validOrigin = CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321)
        let validDestination = CLLocationCoordinate2D(latitude: 47.6205, longitude: -122.3493)
        let invalidOrigin = CLLocationCoordinate2D(latitude: 100.0, longitude: -122.3321) // Invalid latitude
        
        // Valid request
        let validRequest = TripPlanRequest(
            origin: validOrigin,
            destination: validDestination,
            date: Date(),
            time: Date(),
            transportModes: [.transit, .walk],
            maxWalkDistance: 1000,
            wheelchairAccessible: false,
            arriveBy: false
        )
        XCTAssertTrue(validRequest.isValid())
        
        // Invalid request - invalid coordinates
        let invalidRequest = TripPlanRequest(
            origin: invalidOrigin,
            destination: validDestination,
            date: Date(),
            time: Date(),
            transportModes: [.transit, .walk],
            maxWalkDistance: 1000,
            wheelchairAccessible: false,
            arriveBy: false
        )
        XCTAssertFalse(invalidRequest.isValid())
        
        // Invalid request - empty transport modes
        let emptyModesRequest = TripPlanRequest(
            origin: validOrigin,
            destination: validDestination,
            date: Date(),
            time: Date(),
            transportModes: [],
            maxWalkDistance: 1000,
            wheelchairAccessible: false,
            arriveBy: false
        )
        XCTAssertFalse(emptyModesRequest.isValid())
        
        // Invalid request - negative max walk distance
        let negativeDistanceRequest = TripPlanRequest(
            origin: validOrigin,
            destination: validDestination,
            date: Date(),
            time: Date(),
            transportModes: [.transit, .walk],
            maxWalkDistance: -100,
            wheelchairAccessible: false,
            arriveBy: false
        )
        XCTAssertFalse(negativeDistanceRequest.isValid())
    }
    
    func testTransportModeProperties() throws {
        XCTAssertEqual(TransportMode.transit.displayName, "Transit")
        XCTAssertEqual(TransportMode.walk.displayName, "Walk")
        XCTAssertEqual(TransportMode.bike.displayName, "Bike")
        XCTAssertEqual(TransportMode.car.displayName, "Drive")
        
        XCTAssertEqual(TransportMode.transit.systemImageName, "bus")
        XCTAssertEqual(TransportMode.walk.systemImageName, "figure.walk")
        XCTAssertEqual(TransportMode.bike.systemImageName, "bicycle")
        XCTAssertEqual(TransportMode.car.systemImageName, "car")
    }
    
    func testTripPlanRequestTransportModesString() throws {
        let origin = CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321)
        let destination = CLLocationCoordinate2D(latitude: 47.6205, longitude: -122.3493)
        
        let request = TripPlanRequest(
            origin: origin,
            destination: destination,
            date: Date(),
            time: Date(),
            transportModes: [.transit, .walk, .bike],
            maxWalkDistance: 1000,
            wheelchairAccessible: false,
            arriveBy: false
        )
        
        XCTAssertEqual(request.transportModesString, "TRANSIT,WALK,BIKE")
    }
    
    func testTripPlanRequestConvenienceMethods() throws {
        let origin = CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321)
        let destination = CLLocationCoordinate2D(latitude: 47.6205, longitude: -122.3493)
        
        // Test fromServiceData
        let request1 = TripPlanRequest.fromServiceData(
            originCoordinate: origin,
            destinationCoordinate: destination,
            selectedDate: Date(),
            selectedTime: Date(),
            transportModes: [.transit, .walk],
            maxWalkDistance: 1500,
            wheelchairAccessible: true,
            arriveBy: true
        )
        
        XCTAssertEqual(request1.origin.latitude, 47.6062)
        XCTAssertEqual(request1.maxWalkDistance, 1500)
        XCTAssertTrue(request1.wheelchairAccessible)
        XCTAssertTrue(request1.arriveBy)
        
        // Test withCurrentDateTime
        let request2 = TripPlanRequest.withCurrentDateTime(
            originCoordinate: origin,
            destinationCoordinate: destination,
            transportModes: [.bike, .walk],
            maxWalkDistance: 2000,
            wheelchairAccessible: false,
            arriveBy: false
        )
        
        XCTAssertEqual(request2.transportModes, [.bike, .walk])
        XCTAssertEqual(request2.maxWalkDistance, 2000)
        XCTAssertFalse(request2.wheelchairAccessible)
        XCTAssertFalse(request2.arriveBy)
    }
}

// swiftlint:enable force_cast line_length
