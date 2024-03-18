//
//  File.swift
//  
//
//  Created by Sushant Jugran on 15/01/24.
//

import Foundation
import Stripe
import UIKit
import StripePaymentSheet

class StripeAPIClient: NSObject {
    
    var baseURLString: String? = ""
    private var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func startCheckout(completion: @escaping (PaymentSheet?) -> Void) {
        let url = self.baseURL.appendingPathComponent("payment-sheet")
        // MARK: Fetch the PaymentIntent client secret, Ephemeral Key secret, Customer ID, and publishable key
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let customerId = json["customer"] as? String,
                  let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                  let paymentIntentClientSecret = json["paymentIntent"] as? String,
                  let publishableKey = json["publishableKey"] as? String else {
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
            let sheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)
            print(paymentIntentClientSecret)
            completion(sheet)
        })
        task.resume()
    
    }
    
    func trackPaymentStatus() {
        let url = self.baseURL.appendingPathComponent("webhook")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                   else {
                // Handle error
                return
            }
            print(json)
        })
        task.resume()
    }

//    func getCustomer(_ email: String, name: String, success:@escaping (_ responseObject:JSON) -> Void , failure:@escaping (_ errorResponse:JSON?) -> Void) {
//        let url = self.baseURL.appendingPathComponent("getCustomer")
//        AF.request(url, method: .post, parameters: [
//            "email": email,
//            "name": name,
//            ])
//            .validate(statusCode: 200..<300)
//            .responseJSON { responseJSON in
//                switch responseJSON.result {
//                case .success(let response):
//                    success(JSON(response))
//                case .failure(let error):
//                    failure(JSON(error))
//                }
//        }
//    }
    
//    func getEphemeral_keys(withEmail email: String, completion: @escaping STPJSONResponseCompletionBlock) {
//        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
//        AF.request(url, method: .post, parameters: [
//            "email": email,
//            ])
//            .validate(statusCode: 200..<300)
//            .responseJSON { response in
//                switch response.result {
//                case .success(let json):
//                    if let request = response.request?.value {
//                        print("request : \(String(describing: request))")
//                    }
//                    
//                    if let response = response.response {
//                        print("response : \(response)")
//                    }
//                    
//                    completion(json as? [String: AnyObject], nil)
//                case .failure(let error):
//                    completion(nil, error)
//                }
//        }
//    }
    
//    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
//        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
//        AF.request(url, method: .post, parameters: [
//            "api_version": apiVersion,
//            ])
//            .validate(statusCode: 200..<300)
//            .responseJSON { responseJSON in
//                switch responseJSON.result {
//                case .success(let json):
//                    print(json)
//                    completion(json as? [String: AnyObject], nil)
//                case .failure(let error):
//                    print(error)
//                    completion(nil, error)
//                }
//        }
//    }
}
