//
//  File.swift
//  
//
//  Created by Sushant Jugran on 27/02/24.
//

import Foundation

struct PaypalAPIClient {
    
    func getOrderId(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://tabby-aeolian-ophthalmologist.glitch.me/orders") else {return}
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
    
    func captureOrder(orderId: String) {
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
        })
        task.resume()
    }
}
