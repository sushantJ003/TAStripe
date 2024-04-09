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
    
    weak var paypalManager: PaypalManagerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}

extension PaypalContainerViewController: PayPalNativeCheckoutDelegate {

    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError) {
        print(error)
        paypalManager?.resultContinuation?.resume(throwing: error)
    }

    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
        Task.init {
            try await paypalManager?.captureOrder(orderId: result.orderID)
            paypalManager?.prepareResult(sheetResult: .completed)
        }
    }

    public func paypalDidCancel(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
        paypalManager?.resultContinuation?.resume(returning: .cancelled)
    }

    public func paypalWillStart(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
    }
}

