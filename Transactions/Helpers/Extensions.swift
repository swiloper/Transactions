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

extension Date {
    static func day(from: Date) -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: from)
        guard let result = calendar.date(from: components) else { return nil }
        return result
    }
}

extension UserDefaults {
    enum Keys: String {
        case bitcoinRate, lastPriceUpdate
    }
}

extension DateFormatter {
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    static let dayMonthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter
    }()
    
    static let full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss zzz"
        return formatter
    }()
}
