//
//  Category.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import UIKit

enum Category: String, CaseIterable {
    case groceries, taxi, electronics, restaurant, other, income
    
    /// Category system icon.
    var icon: UIImage? {
        switch self {
        case .groceries:
            UIImage(systemName: "basket.fill")
        case .taxi:
            UIImage(systemName: "car.rear.fill")
        case .electronics:
            UIImage(systemName: "macbook.and.ipad")
        case .restaurant:
            UIImage(systemName: "fork.knife")
        case .other:
            UIImage(systemName: "shippingbox.fill")
        case .income:
            UIImage(systemName: "arrow.down.square.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.white, color]))
        }
    }
    
    /// Category system icon color.
    var color: UIColor {
        switch self {
        case .groceries:
            .red
        case .taxi:
            .systemYellow
        case .electronics:
            .orange
        case .restaurant:
            .systemBlue
        case .other:
            .systemBrown
        case .income:
            .darkGray
        }
    }
}
