//
//  ViewController.swift
//
//
//  Created by Sushant Jugran on 15/01/24.
//

import UIKit
import Stripe
import PayPalNativePayments
import CorePayments

public class TAStripeController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        switch TAPaymentManager.shared.mode {
        case .stripe:
            self.setupStripeCheckout()
        case .paypal:
            self.startPaypalCheckout()
        }
    }
    
    func setupStripeCheckout() {
        StripeManager.shared.checkout { [weak self] sheet in
            guard let self = self else {
                return
            }
            
            if let sheet = sheet {
                
                DispatchQueue.main.async {
                    sheet.present(from: self) { paymentResult in
                        StripeManager.shared.prepareResult(sheetResult: paymentResult)
                        print("result is \(paymentResult)")
                    }
                }
            }
        }
    }
    
    func startPaypalCheckout() {
        PaypalManager.shared.payPalNativeClient?.delegate = self
        PaypalManager.shared.initialisePayment()
    }
}

extension TAStripeController: PayPalNativeCheckoutDelegate {
    
    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError) {
        print(error)
        PaypalManager.shared.prepareResult(sheetResult: .failure(error))
    }
    
    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
        PaypalManager.shared.captureOrder(orderId: result.orderID)
    }
    
    public func paypalDidCancel(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
        PaypalManager.shared.prepareResult(sheetResult: .cancelled)
    }
    
    public func paypalWillStart(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
        
    }
}
