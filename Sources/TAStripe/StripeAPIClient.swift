//
//  File.swift
//  
//
//  Created by Sushant Jugran on 15/01/24.
//

import Foundation
import Alamofire
import SwiftyJSON
import Stripe
import UIKit
import StripePaymentSheet

class StripeAPIClient: NSObject, STPCustomerEphemeralKeyProvider {

//    static let shared = StripeAPIClient()
    var paymentSheet: PaymentSheet?
    var baseURLString: String? = "https://equal-sunset-fern.glitch.me/"
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }

    func completeChargeForCustomTextField(_
        token: String,
        customerID: String,
        amount: Int,
        currency: String,
        description: String,
        success:@escaping (_ responseObject:JSON) -> Void , failure:@escaping (_ errorResponse:JSON?) -> Void){
        
        let url = self.baseURL.appendingPathComponent("create_transaction")
        let params: [String: Any] = [
            "source_token": token,
            "source_amount": amount,
            "source_customer": customerID,
            "source_currency": currency,
            "source_description": description
        ]
        
        print(params)
        
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let response):
                    success(JSON(response))
                case .failure(let error):
                    failure(JSON(error))
                }
        }
    }
    
//    public func startCheckout<T: Codable>(param: T, completion: @escaping (String?) -> Void) {
//        let url = self.baseURL.appendingPathComponent("payment-sheet")
//        
//        AF.request(url, method: .post, parameters: param)
//            .validate(statusCode: 200..<300)
//            .responseJSON { responseJSON in
//                switch responseJSON.result {
//                case .success(let response):
//                    let jsonResponse = JSON(response)
//                    print(jsonResponse)
//                case .failure(let error):
//                    completion(nil)
//                }
//        }
//    }
    
    public func startCheckout(completion: @escaping () -> Void) {
        let url = self.baseURL.appendingPathComponent("payment-sheet")
        // MARK: Fetch the PaymentIntent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let customerId = json["customer"] as? String,
                  let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                  let paymentIntentClientSecret = json["paymentIntent"] as? String,
                  let publishableKey = json["publishableKey"] as? String,
                  let self = self else {
                // Handle error
                return
            }
            
            STPAPIClient.shared.publishableKey = publishableKey
            // MARK: Create a PaymentSheet instance
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "Example, Inc."
            configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
            // Set `allowsDelayedPaymentMethods` to true if your business handles
            // delayed notification payment methods like US bank accounts.
            configuration.allowsDelayedPaymentMethods = true
            self.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)  
            completion()
        })
        task.resume()
    
    }

    func getCustomer(_ email: String, name: String, success:@escaping (_ responseObject:JSON) -> Void , failure:@escaping (_ errorResponse:JSON?) -> Void) {
        let url = self.baseURL.appendingPathComponent("getCustomer")
        AF.request(url, method: .post, parameters: [
            "email": email,
            "name": name,
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let response):
                    success(JSON(response))
                case .failure(let error):
                    failure(JSON(error))
                }
        }
    }
    
    func getEphemeral_keys(withEmail email: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        AF.request(url, method: .post, parameters: [
            "email": email,
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    if let request = response.request?.value {
                        print("request : \(String(describing: request))")
                    }
                    
                    if let response = response.response {
                        print("response : \(response)")
                    }
                    
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        AF.request(url, method: .post, parameters: [
            "api_version": apiVersion,
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    print(json)
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    print(error)
                    completion(nil, error)
                }
        }
    }
}

class PaymentContextFooterView: UIView {
    
    var insetMargins: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    var text: String = "" {
        didSet {
            textLabel.text = text
        }
    }
    
    var theme: STPTheme = STPTheme.defaultTheme {
        didSet {
            textLabel.font = theme.smallFont
            textLabel.textColor = theme.secondaryForegroundColor
        }
    }
    
    fileprivate let textLabel = UILabel()
    
    convenience init(text: String) {
        self.init()
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        self.addSubview(textLabel)
        
        self.text = text
        textLabel.text = text
        
    }
    
    override func layoutSubviews() {
        //        textLabel.frame = UIEdgeInsets(top: insetMargins.top, left: insetMargins.left, bottom: insetMargins.bottom, right: insetMargins.right)
        
        textLabel.frame = CGRect(origin: self.bounds.origin, size: self.bounds.size)
        
        //        textLabel.frame = UIEdgeInsetsInsetRect(self.bounds, insetMargins)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // Add 10 pt border on all sides
        var insetSize = size
        insetSize.width -= (insetMargins.left + insetMargins.right)
        insetSize.height -= (insetMargins.top + insetMargins.bottom)
        
        var newSize = textLabel.sizeThatFits(insetSize)
        
        newSize.width += (insetMargins.left + insetMargins.right)
        newSize.height += (insetMargins.top + insetMargins.bottom)
        
        return newSize
    }
}
