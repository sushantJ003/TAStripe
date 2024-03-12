//
//  File.swift
//  
//
//  Created by Sushant Jugran on 21/02/24.
//

import UIKit
import Stripe
import StripePaymentSheet

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
    
    public func setup(companyName: String, appleMerchantIdentifier: String, clientId: String = String(), paymentMode: PaymentMode, environment: PaypalPaymentEnvironment, completion: @escaping (PaymentSheetResult) -> Void) {
        
        mode = paymentMode
        
        switch paymentMode {
        case .stripe:            
            StripeManager.shared.setup(appleMerchantIdentifier: appleMerchantIdentifier, companyName: companyName) { result in
                completion(result)
            }
            
        case .paypal:
            PaypalManager.shared.setup(_clientID: clientId, environment: environment)
        }
    }
    
    public var getPaymentController: UIViewController {
        guard let viewController = UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? TAStripeController else {
            fatalError("ViewController not implemented in storyboard")
        }
        return viewController
    }
}
