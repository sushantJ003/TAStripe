//
//  File.swift
//  
//
//  Created by Sushant Jugran on 15/01/24.
//

import Foundation
import Stripe



public enum StripeManager {
    
    static func setup(appleMerchantIdentifier: String, companyName: String) {
        
        STPPaymentConfiguration.shared.appleMerchantIdentifier = appleMerchantIdentifier
        
        STPPaymentConfiguration.shared.companyName = companyName
    }
}
