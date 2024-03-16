//
//  Extensions.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import Foundation

extension String {
    static let empty: String = ""
}

extension UserDefaults {
    enum Keys: String {
        case bitcoinRate, lastPriceUpdate
    }
}
