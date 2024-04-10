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
    
    func getPaymentContainerWith(result: @escaping (PaymentResult) -> Void) -> UIViewController {
        guard let viewController = UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? PaypalContainerViewController else {
            fatalError("ViewController not implemented in storyboard")
        }
        viewController.manager = self
        self.completion = result
        return viewController
    }
    
    func startCheckout(with controller: UIViewController) {
        
//        do {
//            guard let sheetData = try await checkout() else {
//                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get payment sheet"])
//            }
            
            
                    let sheetData: SheetData = SheetData(customerId: "cus_Pte59UnVy4CCJL", customerEphemeralKeySecret: "ek_test_YWNjdF8xT1lxcDdTRXNGYXg0WG0xLGM0QVlQdEpYUllQM1Q2MUJKWTJkR1lQQ1VITHp1N3g_008X8pxWUT", paymentIntentClientSecret: "pi_3P3qnTSEsFax4Xm11A0zq1TP_secret_5w7zJNlZSFuVWxF5uZH75yt5R", publishableKey: "pk_test_51OYqp7SEsFax4Xm15rybeR0SJpHBnbfrkwGedhk6L2LGi2GQOKQ5AL6tHoOvfcb1Lzj9Ia68i1KOcAHfxNUM0d4200XfijdMJd")
            
            let sheet = preparePaymentSheet(from: sheetData)
        
            Task.init { @MainActor in
                
                var result: PaymentResult = .cancelled
                                
                sheet.present(from: controller) { [weak self] paymentResult in
                    result = self?.getPaymentResult(stripeResult: paymentResult) ?? .cancelled
                    controller.dismiss(animated: true)
                    self?.completion(result)                    
                }
            }
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
