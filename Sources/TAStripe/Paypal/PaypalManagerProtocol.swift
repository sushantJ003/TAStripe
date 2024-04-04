//
//  File.swift
//  
//
//  Created by Sushant Jugran on 01/04/24.
//

import Foundation

public protocol PaypalManagerProtocol: TAPaymentProtocol, AnyObject {
    init(with mode: PaymentMode, paymentInfo: PaymentInfo, apiClient: PaypalAPIClientProtocol)
    func captureOrder(orderId: String)
    var resultContinuation: CheckedContinuation<PaymentResult, Error>? {get set}
}
