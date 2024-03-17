//
//  Category.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import UIKit

enum Category: String, CaseIterable {
    case groceries, taxi, electronics, restaurant, other
    
    /// Name of the category system icon.
    var icon: String {
        switch self {
        case .groceries:
            "basket.fill"
        case .taxi:
            "car.rear.fill"
        case .electronics:
            "macbook.and.ipad"
        case .restaurant:
            "fork.knife"
        case .other:
            "shippingbox.fill"
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
        }
    }
}
