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
    var resultContinuation: CheckedContinuation<PaymentResult, Error>?
    
    required init(paymentInfo: PaymentInfo ,apiClient: StripeAPIClientProtocol) {
        stripeClient = apiClient
    }
    
    init(apiClient: StripeAPIClientProtocol) {
        stripeClient = apiClient
    }
    
    func startCheckout(from controller: UIViewController?) async throws -> PaymentResult {
        
//        do {
//            guard let sheetData = try await checkout() else {
//                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get payment sheet"])
//            }
            
            
                    let sheetData: SheetData = SheetData(customerId: "cus_PtKkOtaWUKrw0t", customerEphemeralKeySecret: "ek_test_YWNjdF8xT1lxcDdTRXNGYXg0WG0xLGdqUzBuU25PalgxYko3ZkZUS0ROOW5lZ2xuQWVCNlg_00K7RbIb7T", paymentIntentClientSecret: "pi_3P3Y5SSEsFax4Xm11lXDj1qL_secret_mv1fhPpGWvvHQHHvQpcnvhrck", publishableKey: "pk_test_51OYqp7SEsFax4Xm15rybeR0SJpHBnbfrkwGedhk6L2LGi2GQOKQ5AL6tHoOvfcb1Lzj9Ia68i1KOcAHfxNUM0d4200XfijdMJd")
            
            let sheet = preparePaymentSheet(from: sheetData)
        
            Task.init { @MainActor in
                
                let container = self.getContainerController()
                controller?.present(container, animated: true)
                var result: PaymentResult = .cancelled
                                
                sheet.present(from: container) { [weak self] paymentResult in
                    result = self?.getPaymentResult(stripeResult: paymentResult) ?? .cancelled
                    self?.resultContinuation?.resume(returning: result)
                }
            }
            
//        } catch {
//            throw error
//        }
//        
        return try await withCheckedThrowingContinuation { continuation in
            resultContinuation = continuation
        }
//        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Something unexted happened"])
    }
    
    func checkout() async throws -> SheetData? {
        return try await stripeClient.startCheckout()
    }
    
    private func preparePaymentSheet(from data: SheetData) -> PaymentSheet {
        STPAPIClient.shared.publishableKey = data.publishableKey
        
        // MARK: Create a PaymentSheet instance
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = stripeClient.companyName
        configuration.customer = .init(id: data.customerId, ephemeralKeySecret: data.customerEphemeralKeySecret)
        // Set `allowsDelayedPaymentMethods` to true if your business handles
        // delayed notification payment methods like US bank accounts.
        configuration.allowsDelayedPaymentMethods = true
        let sheet = PaymentSheet(paymentIntentClientSecret: data.paymentIntentClientSecret, configuration: configuration)
        return sheet
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
