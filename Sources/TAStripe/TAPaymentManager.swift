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

public class TAPaymentManager {
    static public let shared = TAPaymentManager()
    var mode: PaymentMode = .paypal
    
    private init(){}
    
    public func setup(companyName: String, paymentMode: PaymentMode) {
        
        mode = paymentMode
        
        switch paymentMode {
        case .stripe:
            STPPaymentConfiguration.shared.companyName = companyName
            
        case .paypal:
            break
        }
    }
}
