//
//  File.swift
//  
//
//  Created by Sushant Jugran on 27/02/24.
//

import UIKit
import PayPalNativePayments
import CorePayments

public enum PaymentEnvironment {
    case sandbox
    case production
}

class PaypalManager: PaypalManagerProtocol {
    
    var resultContinuation: CheckedContinuation<PaymentResult, Error>?
    var payPalNativeClient: PayPalNativeCheckoutClient?
    var apiClient: PaypalAPIClientProtocol?
    
    required init(with mode: PaymentMode, paymentInfo: PaymentInfo, apiClient: PaypalAPIClientProtocol) {
        let env: Environment = paymentInfo.environment == .production ? .live : .sandbox
        
        let config = CoreConfig(clientID: paymentInfo.clientId, environment: env)
        payPalNativeClient = PayPalNativeCheckoutClient(config: config)
        self.apiClient = apiClient
        
    }
    
    func startCheckout(from controller: UIViewController) async throws -> PaymentResult {
        Task.init {
            let container = prepareContainerView()
            payPalNativeClient?.delegate = container
        }
        
        await initialisePayment()
        return try await withCheckedThrowingContinuation { continuation in
            resultContinuation = continuation
        }
    }
    
    
    private func prepareContainerView() -> PaypalContainerViewController {
        guard let viewController = UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? PaypalContainerViewController else {
            fatalError("ViewController not implemented in storyboard")
        }
        viewController.paypalManager = self
        return viewController
    }
    
    func initialisePayment() async {
        
        do {
            guard let orderId = try await apiClient?.getOrderId() else { fatalError("Could not get orderId") }
            
            let request = PayPalNativeCheckoutRequest(orderID: orderId)
            
            await self.payPalNativeClient?.start(request: request)
            
        } catch {
            debugPrint("Error: \(error)")
        }
    }
    
    func captureOrder(orderId: String) {
        Task.init {
            do {
                try await apiClient?.captureOrder(orderId: orderId)
                self.prepareResult(sheetResult: .completed)
                
            } catch {
                debugPrint("Error: \(error)")
            }
        }
    }
    
    func prepareResult(sheetResult: PaymentResult) {
        resultContinuation?.resume(returning: sheetResult)
    }
}
