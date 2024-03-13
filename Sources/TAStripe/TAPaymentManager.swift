//
//  File.swift
//  
//
//  Created by Sushant Jugran on 21/02/24.
//

import UIKit
import Stripe
import StripePaymentSheet

public enum Result {
    case completed
    case cancelled
    case failure(Error)
}

public class StripeBundle {
   public static let module = Bundle.module
}

public enum PaymentMode {
    case stripe
    case paypal
}

public class TAPaymentManager {
    static public let shared = TAPaymentManager()
    var mode: PaymentMode = .stripe
    
    private init(){}
    
    public func setup(companyName: String, appleMerchantIdentifier: String, clientId: String = String(), paymentMode: PaymentMode, environment: PaypalPaymentEnvironment, completion: @escaping (Result) -> Void) {
        
        mode = paymentMode
        
        switch paymentMode {
        case .stripe:            
            StripeManager.shared.setup(appleMerchantIdentifier: appleMerchantIdentifier, companyName: companyName) { result in
                completion(self.getPaymentResult(stripeResult: result))
            }
            
        case .paypal:
            PaypalManager.shared.setup(_clientID: clientId, environment: environment) { result in
                completion(result)
            }
        }
    }
    
    public var getPaymentController: UIViewController {
        guard let viewController = UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? TAStripeController else {
            fatalError("ViewController not implemented in storyboard")
        }
        return viewController
    }
    
    private func getPaymentResult(stripeResult: PaymentSheetResult) -> Result {
        switch stripeResult {
        case .completed:
            return Result.completed
        case .canceled:
            return Result.cancelled
        case .failed(let error):
            return Result.failure(error)
        }
    }
}
