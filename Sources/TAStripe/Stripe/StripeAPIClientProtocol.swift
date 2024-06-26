//
//  File.swift
//  
//
//  Created by Sushant Jugran on 01/04/24.
//

import Foundation
import StripePaymentSheet
 
public protocol StripeAPIClientProtocol {
    var baseURLString: String {get set}
    var companyName: String {get set}
    func startCheckout() async throws -> SheetData?    
}
