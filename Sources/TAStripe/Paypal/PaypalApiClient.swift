//
//  File.swift
//  
//
//  Created by Sushant Jugran on 27/02/24.
//

import Foundation

class PaypalAPIClient: PaypalAPIClientProtocol {
    
    var baseURLString: String
    private var baseURL: URL {
        if let url = URL(string: baseURLString) {
            return url
        } else {
            fatalError()
        }
    }
    
    init(baseURLString: String) {
        self.baseURLString = baseURLString
    }
    
    func getOrderId() async throws -> String? {
        let url = self.baseURL.appendingPathComponent("orders")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
               else {
            fatalError("Error while parsing data")
        }
        
        return (json["id"] as? String)
    }
    
    func captureOrder(orderId: String) async throws {
        guard let url = URL(string: "https://tabby-aeolian-ophthalmologist.glitch.me//api/orders/\(orderId)/capture") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error while fetching data") }
        
        return
    }
}
