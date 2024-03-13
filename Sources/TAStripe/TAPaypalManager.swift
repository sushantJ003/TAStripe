//
//  File.swift
//  
//
//  Created by Sushant Jugran on 27/02/24.
//

import Foundation
import PayPalNativePayments
import CorePayments

public enum PaypalPaymentEnvironment {
    case sandbox
    case production
}

class PaypalManager {
    
    static let shared: PaypalManager = {
        let instance = PaypalManager()
        return instance
    }()
    
    var resultComletion: ((Result) -> Void)?
    var payPalNativeClient: PayPalNativeCheckoutClient?
    
    private init() {}
    
    func setup(_clientID: String, environment: PaypalPaymentEnvironment, completion: @escaping (Result) -> Void) {
        let env: Environment = environment == .production ? .live : .sandbox
        
        let config = CoreConfig(clientID: _clientID, environment: env)
        payPalNativeClient = PayPalNativeCheckoutClient(config: config)
    }
    
    func initialisePayment() {
        PaypalAPIClient().getOrderId { orderId in
            guard let orderId = orderId else { return }
            let request = PayPalNativeCheckoutRequest(orderID: orderId)
            Task {
                await self.payPalNativeClient?.start(request: request)
            }
        }
    }
    
    func captureOrder(orderId: String) {
        PaypalAPIClient().captureOrder(orderId: orderId) {
            PaypalManager.shared.prepareResult(sheetResult: .completed)
        }
    }
    
    func prepareResult(sheetResult: Result) {
        resultComletion?(sheetResult)
    }
}
