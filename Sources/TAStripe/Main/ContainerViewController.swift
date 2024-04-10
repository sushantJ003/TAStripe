//
//  PaymentContainerViewController.swift
//
//
//  Created by Sushant Jugran on 04/04/24.
//

import UIKit
import PayPalNativePayments
import CorePayments

class ContainerViewController: UIViewController {
    
    weak var manager: BasePaymentProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        manager?.startCheckout(with: self)
    }
}

// delegate methods of Paypal checkout sheet
extension ContainerViewController: PayPalNativeCheckoutDelegate {
    
    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError) {
        print(error)
        (manager as? PaypalManagerProtocol)?.completion(.failure(error))
    }
    
    public func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
        Task.init {
            try await (manager as? PaypalManagerProtocol)?.captureOrder(orderId: result.orderID)
            (manager as? PaypalManagerProtocol)?.prepareResult(sheetResult: .completed)
        }
    }
    
    public func paypalDidCancel(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
        (manager as? PaypalManagerProtocol)?.completion(.cancelled)
    }
    
    public func paypalWillStart(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
    }
}

