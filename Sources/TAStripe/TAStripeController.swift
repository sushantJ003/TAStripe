//
//  ViewController.swift
//  
//
//  Created by Sushant Jugran on 15/01/24.
//

import UIKit
import Stripe
import ObjectMapper
import SVProgressHUD
import SwiftyJSON

public class TAStripeController: UIViewController {
    var stripeClient: StripeAPIClient?
    @IBOutlet weak var statusLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        stripeClient = StripeAPIClient()
        self.setupPaymentSheet()
    }
    
    func setupPaymentSheet() {
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
                            print("Payment failed: \(error)")
                            self.statusLabel.text = "Payment failed"
                        }
                    }
                }
            }
        }
    }
}
