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
    let completion: (PaymentResult) -> Void
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

public protocol TAPaymentFactoryManager {}

public extension TAPaymentFactoryManager {
    func getPaymentMethod(mode: PaymentMode, paymentInfo: PaymentInfo) -> TAPaymentProtocol {
        switch mode {
        case .stripe:
            return StripeManager(with: mode, paymentInfo: paymentInfo, apiClient: StripeAPIClient(baseURLString: paymentInfo.absoluteBaseUrl))
        case .paypal:
            return PaypalManager(with: mode, paymentInfo: paymentInfo, apiClient: PaypalAPIClient(baseURLString: paymentInfo.absoluteBaseUrl))
        }
    }
}




//TODO:

//extension TAStripeController: PayPalNativeCheckoutDelegate {
//
//    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError) {
//        print(error)
//        PaypalManager.shared.prepareResult(sheetResult: .failure(error))
//    }
//
//    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
//        PaypalManager.shared.captureOrder(orderId: result.orderID)
//    }
//
//    public func paypalDidCancel(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
//        PaypalManager.shared.prepareResult(sheetResult: .cancelled)
//    }
//
//    public func paypalWillStart(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
//
//    }
//}

