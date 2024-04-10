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
    var completion: ((PaymentResult) -> Void)!
    
    required init(paymentInfo: PaymentInfo ,apiClient: StripeAPIClientProtocol) {
        stripeClient = apiClient
    }
    
    init(apiClient: StripeAPIClientProtocol) {
        stripeClient = apiClient
    }
    
    func getContainerController(action: @escaping (PaymentResult) -> Void) -> UIViewController {
        guard let viewController = UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? PaypalContainerViewController else {
            fatalError("ViewController not implemented in storyboard")
        }
        viewController.manager = self
//        Task.init {
//            action(try await startCheckout(with: viewController))
//            print("abc")
//        }
        self.completion = action
        return viewController
    }
    
    func startCheckout(with controller: UIViewController) {
        
//        do {
//            guard let sheetData = try await checkout() else {
//                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get payment sheet"])
//            }
            
            
                    let sheetData: SheetData = SheetData(customerId: "cus_PtSw63B7HZklnu", customerEphemeralKeySecret: "ek_test_YWNjdF8xT1lxcDdTRXNGYXg0WG0xLHpvUzIyd3JwRW1nM01KNUF4Q0xsOWNZb2RUdVdqNEU_00T89DKuI2", paymentIntentClientSecret: "pi_3P3g0VSEsFax4Xm118yRu83G_secret_agZNFhn8fOd3LqbDMlJdDBUFt", publishableKey: "pk_test_51OYqp7SEsFax4Xm15rybeR0SJpHBnbfrkwGedhk6L2LGi2GQOKQ5AL6tHoOvfcb1Lzj9Ia68i1KOcAHfxNUM0d4200XfijdMJd")
            
            let sheet = preparePaymentSheet(from: sheetData)
        
            Task.init { @MainActor in
                
                var result: PaymentResult = .cancelled
                                
                sheet.present(from: controller) { [weak self] paymentResult in
                    result = self?.getPaymentResult(stripeResult: paymentResult) ?? .cancelled
                    self?.completion(result)
//                    self?.resultContinuation?.resume(returning: result)
                }
            }
            
//        } catch {
//            throw error
//        }
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            resultContinuation = continuation
//        }
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
