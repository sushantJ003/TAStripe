//
//  File.swift
//  
//
//  Created by Sushant Jugran on 22/03/24.
//

import Foundation

public protocol StripeManagerProtocol: TAPaymentProtocol {
    init(with mode: PaymentMode, paymentInfo: PaymentInfo, apiClient: StripeAPIClientProtocol)
}
