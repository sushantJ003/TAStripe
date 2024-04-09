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
    let companyName: String
    
    public init(clientId: String, environment: PaymentEnvironment, absoluteBaseUrl: String, companyName: String) {
        self.clientId = clientId
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

public protocol TAPaymentProtocol {
    func startCheckout(from controller: UIViewController?) async throws -> PaymentResult    
}

public extension TAPaymentProtocol {
    func getContainerController() -> UIViewController {
        guard let viewController = UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? PaypalContainerViewController else {
            fatalError("ViewController not implemented in storyboard")
        }
        return viewController
    }
}

public struct TAPaymentFactoryManager {
    public init() {}
    
    public func getPaymentMethod(mode: PaymentMode, paymentInfo: PaymentInfo) -> TAPaymentProtocol {
        switch mode {
        case .stripe:
            let ree = StripeManager(paymentInfo: paymentInfo, apiClient: StripeAPIClient(baseURLString: paymentInfo.absoluteBaseUrl, companyName: paymentInfo.companyName))
            print("protocol is: \(ree)")
            return ree
        case .paypal:
            return PaypalManager(paymentInfo: paymentInfo, apiClient: PaypalAPIClient(baseURLString: paymentInfo.absoluteBaseUrl))
        }
    }
}
