//
//  File.swift
//  
//
//  Created by Sushant Jugran on 22/03/24.
//

import Foundation

protocol StripeManagerProtocol: BasePaymentProtocol {
    init(paymentInfo: PaymentInfo, apiClient: StripeAPIClientProtocol)
}
