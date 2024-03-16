//
//  EndpointPath.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import Foundation

enum EndpointPath {
    static let base = "https://api.coindesk.com"
    static let currentBitcoinPrice = base + "/v1/bpi/currentprice.json"
}
