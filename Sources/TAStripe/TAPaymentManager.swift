//
//  File.swift
//  
//
//  Created by Sushant Jugran on 21/02/24.
//

import Foundation
import Stripe

public enum PaymentMode {
    case stripe
    case paypal
}

public struct TAPaymentManager {
    static public let shared = TAPaymentManager()
    var mode: PaymentMode = .paypal
    
    private init(){}
    
    public mutating func setup(publishableKey: String, appleMerchantIdentifier: String, companyName: String, paymentMode: PaymentMode) {
        
        mode = paymentMode
        
        switch paymentMode {
        case .stripe:
            STPAPIClient.shared.publishableKey = publishableKey
            
            STPPaymentConfiguration.shared.appleMerchantIdentifier = appleMerchantIdentifier
            
            STPPaymentConfiguration.shared.companyName = companyName
        case .paypal:
            break
        }
    }
}
