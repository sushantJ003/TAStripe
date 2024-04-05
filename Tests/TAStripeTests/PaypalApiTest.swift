//
//  File.swift
//
//
//  Created by Sushant Jugran on 05/04/24.
//

import XCTest
@testable import TAStripe

final class MockPaypalApiClient: PaypalAPIClientProtocol {
    var baseURLString: String = ""
    
    func getOrderId() async throws -> String? {
        // Mock the data and response here
        let jsonString = """
                    {
                        "id": "myOrderId"
                    }
                """
        
        if let data = jsonString.data(using: .utf8) {
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else {
                
                fatalError("Error while parsing data")
            }
            return (json["id"] as? String)
            
        } else {
            let error = NSError(domain: "MockNetworkingServiceErrorDomain", code: -1, userInfo: nil)
            throw error
        }
    }
    
    func captureOrder(orderId: String) async throws {
        // Simulate a successful API response with status code 200        
        return
    }
}

class PaypalManagerTest: XCTestCase {
    var manager: PaypalManager!
    
    override func setUp() {
        super.setUp()
        // Use the mock networking service during testing
        let mockNetworkingService = MockPaypalApiClient()
        manager = PaypalManager(apiClient: mockNetworkingService)
    }
    override func tearDown() {
        manager = nil
        super.tearDown()
    }
    
    func testGetOrderId() {
        let expectation = self.expectation(description: "Fetch order id")
        Task.init {
            do {
                let orderId = try await manager.initialisePayment()
                XCTAssertEqual(orderId, "myOrderId")
            } catch {
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testCaptureOrder() {
        let expectation = self.expectation(description: "Fetch order id")
        Task.init {
            do {
                try await manager.captureOrder(orderId: "myOrderId")
                
            } catch {
                XCTFail("Error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}
