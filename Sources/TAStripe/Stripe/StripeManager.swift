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
    
    required init(paymentInfo: PaymentInfo ,apiClient: StripeAPIClientProtocol) {
        stripeClient = apiClient
    }
    
    init(apiClient: StripeAPIClientProtocol) {
        stripeClient = apiClient
    }
    
    func startCheckout(from controller: UIViewController?) async throws -> PaymentResult {
        
        do {
            guard let sheetData = try await checkout() else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get payment sheet"])
            }
            let sheet = preparePaymentSheet(from: sheetData)
            
            Task.init {
                var result: PaymentResult = .cancelled
                                
                guard let viewController = await UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? PaypalContainerViewController else {
                    fatalError("ViewController not implemented in storyboard")
                }
                
                
                sheet.present(from: viewController) { paymentResult in
                    result = self.getPaymentResult(stripeResult: paymentResult)
                }
                return result
            }
            
        } catch {
            throw error
        }
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Something unexted happened"])
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
