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
    var stripeClient: StripeAPIClient?
    
    @IBOutlet weak var statusLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        switch TAPaymentManager.shared.mode {
        case .stripe:
            stripeClient = StripeAPIClient()
            self.setupStripeCheckout()
        case .paypal:
            self.startPaypalCheckout()
        }
    }
    
    func setupStripeCheckout() {
        stripeClient?.startCheckout { [weak self] in
            guard let self = self else {
                return
            }
            
            if let sheet = stripeClient?.paymentSheet {
                
                DispatchQueue.main.async {
                    sheet.present(from: self) { paymentResult in
                        // MARK: Handle the payment result
                        switch paymentResult {
                        case .completed:
                            print("Your order is confirmed")
                            self.statusLabel.text = "Payment completed"
                        case .canceled:
                            print("Canceled!")
                            self.statusLabel.text = "Payment canceled"
                        case .failed(let error):
                            self.statusLabel.text = "Payment failed"
                            self.statusLabel.text = "Payment failed: \(error)"
                        }
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
    }
    
    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
        print(result)
    }
    
    public func paypalDidCancel(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
        
    }
    
    public func paypalWillStart(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
        
    }
}
