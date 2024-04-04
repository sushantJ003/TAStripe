//
//  File.swift
//  
//
//  Created by Sushant Jugran on 01/04/24.
//

import Foundation

public protocol PaypalAPIClientProtocol {
    var baseURLString: String {get set}
    func getOrderId() async throws -> String?
    func captureOrder(orderId: String) async throws
}
