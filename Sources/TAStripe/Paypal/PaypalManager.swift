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
    
    var payPalNativeClient: PayPalNativeCheckoutClient?
    var apiClient: PaypalAPIClientProtocol?
    var completion: ((PaymentResult) -> Void)!
    
    init(apiClient: PaypalAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    required init(paymentInfo: PaymentInfo, apiClient: PaypalAPIClientProtocol) {
        let env: Environment = paymentInfo.environment == .production ? .live : .sandbox
        
        let config = CoreConfig(clientID: paymentInfo.clientId, environment: env)
        payPalNativeClient = PayPalNativeCheckoutClient(config: config)
        self.apiClient = apiClient
    }
    
    func getPaymentContainerWith(result: @escaping (PaymentResult) -> Void) -> UIViewController {
        guard let viewController = UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? ContainerViewController else {
            fatalError("ViewController not implemented in storyboard")
        }
        viewController.manager = self
        self.completion = result
        return viewController
    }
    
    func startCheckout(with controller: UIViewController) {
        guard let container = controller as? ContainerViewController else { fatalError() }
        payPalNativeClient?.delegate = container
        
        Task.init {
            let orderId = try await initialisePayment()
            
            let request = PayPalNativeCheckoutRequest(orderID: orderId)
            
            await self.payPalNativeClient?.start(request: request)
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
        completion(sheetResult)
    }
}
