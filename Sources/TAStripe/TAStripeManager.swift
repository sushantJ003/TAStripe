//
//  File.swift
//  
//
//  Created by Sushant Jugran on 15/01/24.
//

import Foundation
import StripePaymentSheet
import Stripe

class StripeManager {
    var resultComletion: ((PaymentSheetResult) -> Void)?
    
    var stripeClient: StripeAPIClient = StripeAPIClient()
    static let shared: StripeManager = {
        let instance = StripeManager()
        return instance
    }()
    
    private init() {}
    
    func setup(appleMerchantIdentifier: String, companyName: String, baseUrlString: String, completion: @escaping (PaymentSheetResult) -> Void) {
        
        STPPaymentConfiguration.shared.appleMerchantIdentifier = appleMerchantIdentifier
        
        STPPaymentConfiguration.shared.companyName = companyName
        resultComletion = completion
        stripeClient.baseURLString = baseUrlString
    }
    
    func prepareResult(sheetResult: PaymentSheetResult) {
        resultComletion?(sheetResult)
    }
    
    func checkout(completion: @escaping (PaymentSheet?) -> Void) {
        stripeClient.startCheckout { sheet in
            completion(sheet)
        }
    }
}
