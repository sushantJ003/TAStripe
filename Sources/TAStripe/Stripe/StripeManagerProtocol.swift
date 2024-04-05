//
//  File.swift
//  
//
//  Created by Sushant Jugran on 22/03/24.
//

import Foundation

public protocol StripeManagerProtocol: TAPaymentProtocol {
    init(paymentInfo: PaymentInfo, apiClient: StripeAPIClientProtocol)
}
