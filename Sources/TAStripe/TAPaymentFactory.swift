//
//  File.swift
//  
//
//  Created by Sushant Jugran on 22/03/24.
//

import UIKit

public class StripeBundle {
   public static let module = Bundle.module
}

public struct PaymentInfo {
    let clientId: String
    let environment: PaymentEnvironment
    let absoluteBaseUrl: String
    let coompanyName: String
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

public protocol TAPaymentProtocol {
    func startCheckout(from controller: UIViewController) async throws -> PaymentResult
}

public struct TAPaymentFactoryManager {
    func getPaymentMethod(mode: PaymentMode, paymentInfo: PaymentInfo) -> TAPaymentProtocol {
        switch mode {
        case .stripe:
            return StripeManager(with: mode, paymentInfo: paymentInfo, apiClient: StripeAPIClient(baseURLString: paymentInfo.absoluteBaseUrl))
        case .paypal:
            return PaypalManager(with: mode, paymentInfo: paymentInfo, apiClient: PaypalAPIClient(baseURLString: paymentInfo.absoluteBaseUrl))
        }
    }
}
