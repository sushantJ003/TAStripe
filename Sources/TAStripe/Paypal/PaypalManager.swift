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
    
    init(apiClient: PaypalAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    required init(paymentInfo: PaymentInfo, apiClient: PaypalAPIClientProtocol) {
        let env: Environment = paymentInfo.environment == .production ? .live : .sandbox
        
        let config = CoreConfig(clientID: paymentInfo.clientId, environment: env)
        payPalNativeClient = PayPalNativeCheckoutClient(config: config)
        self.apiClient = apiClient
    }
    
    func getContainerController() -> UIViewController {
        guard let viewController = UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? PaypalContainerViewController else {
            fatalError("ViewController not implemented in storyboard")
        }
        viewController.manager = self
        return viewController
    }
    
    func startCheckout() async throws -> PaymentResult {
        Task.init {
            guard let container = getContainerController() as? PaypalContainerViewController else { fatalError() }
            payPalNativeClient?.delegate = container
        }
        
        let orderId = try await initialisePayment()
        
        let request = PayPalNativeCheckoutRequest(orderID: orderId)
        
        await self.payPalNativeClient?.start(request: request)
        
        return try await withCheckedThrowingContinuation { continuation in
            resultContinuation = continuation
        }
    }
    
    func initialisePayment() async throws -> String {
        
        do {
            guard let orderId = try await apiClient?.getOrderId() else { fatalError("Could not get orderId") }
            return orderId
            
        } catch {
            throw error
        }
    }
    
    func captureOrder(orderId: String) async throws {
        do {
            try await apiClient?.captureOrder(orderId: orderId)
            return
            
        } catch {
            throw error
        }
    }
    
    func prepareResult(sheetResult: PaymentResult) {
        resultContinuation?.resume(returning: sheetResult)
    }
}
