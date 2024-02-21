//
//  File.swift
//  
//
//  Created by Sushant Jugran on 21/02/24.
//

import UIKit
import Stripe

public class StripeBundle {
   public static let module = Bundle.module
}

public enum PaymentMode {
    case stripe
    case paypal
}

public class TAPaymentManager {
    static public let shared = TAPaymentManager()
    var mode: PaymentMode = .paypal
    
    private init(){}
    
    public func setup(companyName: String, appleMerchantIdentifier: String, paymentMode: PaymentMode) {
        
        mode = paymentMode
        
        switch paymentMode {
        case .stripe:            
            StripeManager.setup(appleMerchantIdentifier: appleMerchantIdentifier, companyName: companyName)
        case .paypal:
            break
        }
    }
    
    public var getPaymentController: UIViewController {
        switch mode {
        case .stripe:
            guard let viewController = UIStoryboard(name: "Storyboard", bundle: StripeBundle.module).instantiateInitialViewController() as? TAStripeController else {
                fatalError("ViewController not implemented in storyboard")
            }
            return viewController
            
        case .paypal:
            return UIViewController()
        }
        
    }
}
