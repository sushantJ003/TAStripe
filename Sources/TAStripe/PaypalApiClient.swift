//
//  File.swift
//  
//
//  Created by Sushant Jugran on 27/02/24.
//

import Foundation

class PaypalAPIClient {
    
    var baseURLString: String? = "https://tabby-aeolian-ophthalmologist.glitch.me/"
    private var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func getOrderId(completion: @escaping (String?) -> Void) {
        let url = self.baseURL.appendingPathComponent("orders")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                   else {
                return
            }
            completion(json["id"] as? String)            
        })
        task.resume()
    }
    
    func captureOrder(orderId: String, completion: @escaping () -> Void) {
        guard let url = URL(string: "https://tabby-aeolian-ophthalmologist.glitch.me//api/orders/\(orderId)/capture") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                   else {
                return
            }
            print(json)
            completion()
        })
        task.resume()
    }
}
