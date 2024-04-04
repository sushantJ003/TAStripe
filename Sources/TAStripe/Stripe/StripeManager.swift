//
//  File.swift
//  
//
//  Created by Sushant Jugran on 15/01/24.
//

import UIKit
import StripePaymentSheet
import Stripe

class StripeManager: StripeManagerProtocol {
        
    var stripeClient: StripeAPIClientProtocol
    
    required init(with mode: PaymentMode, paymentInfo: PaymentInfo ,apiClient: StripeAPIClientProtocol) {
        stripeClient = apiClient
    }
    
    func startCheckout(from controller: UIViewController) async throws -> PaymentResult {
        
        do {
            let sheet = try await checkout()
            Task.init {
                var result: PaymentResult = .cancelled
                sheet?.present(from: controller) { paymentResult in
                    result = self.getPaymentResult(stripeResult: paymentResult)
                }
                return result
            }
            
        } catch {
            throw error
        }
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Something unexted happened"])
    }
    
    private func checkout() async throws -> PaymentSheet? {
        return try await stripeClient.startCheckout()
    }
    
    private func getPaymentResult(stripeResult: PaymentSheetResult) -> PaymentResult {
        switch stripeResult {
        case .completed:
            return .completed
        case .canceled:
            return .cancelled
        case .failed(let error):
            return .failure(error)
        }
    }
}
