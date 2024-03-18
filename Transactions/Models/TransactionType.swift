//
//  TransactionType.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 18.03.2024.
//

import UIKit

@objc
public enum TransactionType: Int16 {
    case income, expense
    
    var title: String {
        switch self {
        case .income:
            "Income"
        case .expense:
            "Expense"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .income:
            UIImage(systemName: "arrow.down.square.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.white, .darkGray]))
        case .expense:
            nil
        }
    }
}
