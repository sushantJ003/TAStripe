//
//  File.swift
//  
//
//  Created by Sushant Jugran on 10/04/24.
//

import Foundation

public class StripeBundle {
   public static let module = Bundle.module
}

/// Information required by package to completely initiate payment SDKs
///
/// - Parameter paypalClientId: paypal client id required to initiate the sdk
/// - Parameter environment: enum value to select between sandbox or live mode
/// - Parameter absoluteBaseUrl: base url of the server hosting the payment APIs
/// - Parameter companyName: name to be show on stripe payment sheet
public struct PaymentInfo {
    let paypalClientId: String
    let environment: PaymentEnvironment
    let absoluteBaseUrl: String
    let companyName: String
    
    public init(paypalClientId: String, environment: PaymentEnvironment, absoluteBaseUrl: String, companyName: String) {
        self.paypalClientId = paypalClientId
        self.environment = environment
        self.absoluteBaseUrl = absoluteBaseUrl
        self.companyName = companyName
    }
}

public enum PaymentResult {
    case completed
    case cancelled
    case failure(Error)
}

public enum PaymentMode {
    case stripe
    case paypal
}
