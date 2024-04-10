//
//  File.swift
//  
//
//  Created by Sushant Jugran on 22/03/24.
//

import UIKit

/// Base protocol containing all the required functions which other payment managers must conform
protocol BasePaymentProtocol: TAPaymentProtocol {
    
    /// Initate the checkout process from the controller .
    ///
    /// - Parameters:
    ///     - controller: Payment container controller returned by TAPaymentProtocol.
    
    func startCheckout(with controller: UIViewController)
    
    /// Completion callback when the payment process is done.
    ///
    /// - Returns: an Enum of type PaymentResult.
    var completion: ((PaymentResult) -> Void)! { get set }
}


/// Interface between client and internal classes. Responsible to provide payment controller to be presented and then the payment result.

public protocol TAPaymentProtocol: AnyObject {
    
    /// Provide a viewcontroller with the result callback `result`.
    ///
    /// ```
    /// getPaymentContainerWith(result: { result in
    /// print(result)
    /// })
    /// ```
    /// - Parameters:
    ///     - result: Completion block with return type PaymentResult.
    ///
    /// - Returns: a viewController containing the payment coponents.
    func getPaymentContainerWith(result: @escaping (PaymentResult) -> Void) -> UIViewController
}

public struct TAPaymentManager {
    public init() {}
    
    /// Provide a PaymentProtocol for the given `mode` and `paymentInfo`.
    ///
    /// ```
    /// getPaymentMethod(mode: .stripe, paymentInfo: PaymentInfo(clientId: Constants.clientId, environment: .sandbox, absoluteBaseUrl: Constants.stripeBaseurl, companyName: Constants.companyName))
    /// ```
    ///
    /// - Parameters:
    ///     - mode: Mode to switch between multiple payment mode.
    ///     - paymentInfo: PaymentInfo is a structure containing all the required field needed to invoke payment SDK
    ///
    /// - Returns: An interface of type TAPaymentProtocol which is sole mediater between client and payment SDKs.
    public func getPaymentMethod(mode: PaymentMode, paymentInfo: PaymentInfo) -> TAPaymentProtocol {
        switch mode {
        case .stripe:
            return StripeManager(paymentInfo: paymentInfo, apiClient: StripeAPIClient(baseURLString: paymentInfo.absoluteBaseUrl, companyName: paymentInfo.companyName))            
            
        case .paypal:
            return PaypalManager(paymentInfo: paymentInfo, apiClient: PaypalAPIClient(baseURLString: paymentInfo.absoluteBaseUrl))
        }
    }
}
