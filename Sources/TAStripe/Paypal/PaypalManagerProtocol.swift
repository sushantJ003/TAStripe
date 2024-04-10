//
//  File.swift
//  
//
//  Created by Sushant Jugran on 01/04/24.
//

import Foundation

protocol PaypalManagerProtocol: BasePaymentProtocol, AnyObject {
    var resultContinuation: CheckedContinuation<PaymentResult, Error>? {get set}
    init(paymentInfo: PaymentInfo, apiClient: PaypalAPIClientProtocol)
    func captureOrder(orderId: String) async throws
    func prepareResult(sheetResult: PaymentResult)
}
