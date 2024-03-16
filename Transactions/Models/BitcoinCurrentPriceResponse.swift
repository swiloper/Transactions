//
//  BitcoinCurrentPriceResponse.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import Foundation

struct BitcoinCurrentPriceResponse: Decodable {
    let time: Time
    let price: Price
    
    enum CodingKeys: String, CodingKey {
        case time
        case price = "bpi"
    }
}

struct Time: Decodable {
    let updated: String
}

struct Price: Decodable {
    let dollar: Currency
    
    enum CodingKeys: String, CodingKey {
        case dollar = "USD"
    }
}

struct Currency: Decodable {
    let rate: String
}
