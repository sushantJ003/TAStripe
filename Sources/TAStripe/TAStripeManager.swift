//
//  File.swift
//  
//
//  Created by Sushant Jugran on 15/01/24.
//

import Foundation
import Stripe

public class StripeBundle {
   public static let module = Bundle.module
}

public enum Manager {
    
    public static func setup(publishableKey: String, appleMerchantIdentifier: String, companyName: String) {
        
        STPAPIClient.shared.publishableKey = publishableKey
        
        STPPaymentConfiguration.shared.appleMerchantIdentifier = appleMerchantIdentifier
        
        STPPaymentConfiguration.shared.companyName = companyName
    }
}
