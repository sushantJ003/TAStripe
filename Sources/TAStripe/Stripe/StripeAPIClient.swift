//
//  File.swift
//  
//
//  Created by Sushant Jugran on 15/01/24.
//

import Foundation
import Stripe
import UIKit
import StripePaymentSheet

class StripeAPIClient: StripeAPIClientProtocol {
    
    var baseURLString: String
    private var baseURL: URL {
        if let url = URL(string: baseURLString) {
            return url
        } else {
            fatalError()
        }
    }
    
    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }
    
    func startCheckout() async throws -> PaymentSheet? {
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
        STPAPIClient.shared.publishableKey = publishableKey
        
        // MARK: Create a PaymentSheet instance
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Example, Inc."
        configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
        // Set `allowsDelayedPaymentMethods` to true if your business handles
        // delayed notification payment methods like US bank accounts.
        configuration.allowsDelayedPaymentMethods = true
        let sheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
        return sheet
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
