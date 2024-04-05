//
//  File.swift
//
//
//  Created by Sushant Jugran on 05/04/24.
//

import XCTest
import StripePaymentSheet
@testable import TAStripe

final class MockStripeApiClient: StripeAPIClientProtocol {
    var baseURLString: String = ""
    
    var companyName: String = ""
    
    func startCheckout() async throws -> SheetData? {
        // Mock the data and response here
        let jsonString = """
                    {
                        "paymentIntent": "intent",
                        "customer": "customer",
                        "ephemeralKey": "ephemeralKey",
                        "publishableKey": "publishableKey"
                    }
                """
        
        if let data = jsonString.data(using: .utf8) {
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any], let customerId = json["customer"] as? String,
                  let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                  let paymentIntentClientSecret = json["paymentIntent"] as? String,
                  let publishableKey = json["publishableKey"] as? String else {
                throw NSError(domain: "MockNetworkingServiceErrorDomain", code: -1, userInfo: nil)
            }
            let sheetData = SheetData(customerId: customerId, customerEphemeralKeySecret: customerEphemeralKeySecret, paymentIntentClientSecret: paymentIntentClientSecret, publishableKey: publishableKey)
            return sheetData
            
        } else {
            let error = NSError(domain: "MockNetworkingServiceErrorDomain", code: -1, userInfo: nil)
            throw error
        }
    }
}

class StripeManagerTest: XCTestCase {
    var manager: StripeManager!
    
    override func setUp() {
        super.setUp()
        // Use the mock networking service during testing
        let mockNetworkingService = MockStripeApiClient()
        manager = StripeManager(apiClient: mockNetworkingService)
    }
    override func tearDown() {
        manager = nil
        super.tearDown()
    }
    
    func testCheckout() {
        let expectation = self.expectation(description: "Fetch order id")
        Task.init {
            do {
                let sheetData = try await manager.checkout()
                XCTAssertEqual(sheetData?.paymentIntentClientSecret ?? "", "intent")
                XCTAssertEqual(sheetData?.customerId ?? "", "customer")
                XCTAssertEqual(sheetData?.customerEphemeralKeySecret ?? "", "ephemeralKey")
                XCTAssertEqual(sheetData?.publishableKey ?? "", "publishableKey")
                
            } catch {
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
