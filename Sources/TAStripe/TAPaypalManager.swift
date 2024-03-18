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
    let apiClient: PaypalAPIClient = PaypalAPIClient()
    
    private init() {}
    
    func setup(_clientID: String, environment: PaypalPaymentEnvironment, baseUrlString: String , completion: @escaping (Result) -> Void) {
        let env: Environment = environment == .production ? .live : .sandbox
        
        let config = CoreConfig(clientID: _clientID, environment: env)
        payPalNativeClient = PayPalNativeCheckoutClient(config: config)
        apiClient.baseURLString = baseUrlString
        resultComletion = completion
    }
    
    func initialisePayment() {
        apiClient.getOrderId { orderId in
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
        print(sheetResult)
        resultComletion?(sheetResult)
    }
}
