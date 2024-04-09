//
//  PaymentContainerViewController.swift
//  
//
//  Created by Sushant Jugran on 04/04/24.
//

import UIKit
import PayPalNativePayments
import CorePayments

class PaypalContainerViewController: UIViewController {
    
    weak var manager: TAPaymentProtocol?
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }    
    
}

extension PaypalContainerViewController: PayPalNativeCheckoutDelegate {

    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError) {
        print(error)
        (manager as? PaypalManagerProtocol)?.resultContinuation?.resume(throwing: error)
    }

    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
        Task.init {
            try await (manager as? PaypalManagerProtocol)?.captureOrder(orderId: result.orderID)
            (manager as? PaypalManagerProtocol)?.prepareResult(sheetResult: .completed)
        }
    }

    public func paypalDidCancel(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
        (manager as? PaypalManagerProtocol)?.resultContinuation?.resume(returning: .cancelled)
    }

    public func paypalWillStart(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
    }
}

