//
//  File.swift
//
//
//  Created by Sushant Jugran on 15/01/24.
//

import Foundation
import UIKit

public struct SheetData {
    let customerId: String
    let customerEphemeralKeySecret: String
    let paymentIntentClientSecret: String
    let publishableKey: String
}

class StripeAPIClient: StripeAPIClientProtocol {
    
    var baseURLString: String
    var companyName: String
    private var baseURL: URL {
        if let url = URL(string: baseURLString) {
            return url
        } else {
            fatalError()
        }
    }
    
    init(baseURLString: String, companyName: String) {
        self.baseURLString = baseURLString
        self.companyName = companyName
    }
    
    func startCheckout() async throws -> SheetData? {
        let url = self.baseURL.appendingPathComponent("payment-sheet")
        // MARK: Fetch the PaymentIntent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
            let customerId = json["customer"] as? String,
            let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
            let paymentIntentClientSecret = json["paymentIntent"] as? String,
            let publishableKey = json["publishableKey"] as? String else {
            // Handle error
            fatalError("Error while parsing data")
        }
        let sheetData = SheetData(customerId: customerId, customerEphemeralKeySecret: customerEphemeralKeySecret, paymentIntentClientSecret: paymentIntentClientSecret, publishableKey: publishableKey)
        
        return sheetData
    }
    
    func trackPaymentStatus() {
        let url = self.baseURL.appendingPathComponent("webhook")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            else {
                // Handle error
                return
            }
            print("Payment result: \(json)")
        })
        task.resume()
    }
    
}
