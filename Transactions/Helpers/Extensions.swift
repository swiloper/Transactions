//
//  Extensions.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import UIKit

// MARK: - String

extension String {
    static let empty: String = ""
}

// MARK: - Date

extension Date {
    static func day(from: Date) -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: from)
        guard let result = calendar.date(from: components) else { return nil }
        return result
    }
}

// MARK: - NumberFormatter

extension NumberFormatter {
    static func bitcoinAmount(maximumFractionDigits: Int = 8) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = .zero
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
        return formatter
    }
}

// MARK: - DateFormatter

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

// MARK: - UIAlertController

extension UIAlertController {
    static func replenishAlertController(doneAction: @escaping (Double) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Replenish", message: "Specify bitcoin quantity you wish to deposit.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter amount in BTC"
            textField.keyboardType = .decimalPad
            textField.addAction(UIAction { action in
                if let sender = action.sender as? UITextField {
                    var isEnabled = false
                    
                    if let text = sender.text {
                        sender.text = text.replacingOccurrences(of: ",", with: ".")
                        let amount = Double(text)
                        isEnabled = !(amount == nil || amount == .zero)
                    }
                    
                    if let index = alert.actions.firstIndex(where: { $0.title == "Done" }) {
                        alert.actions[index].isEnabled = isEnabled
                    }
                }
            }, for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(
            UIAlertAction(title: "Done", style: .default) { _ in
                if let textFields = alert.textFields, let first = textFields.first, let text = first.text, let amount = Double(text) {
                    doneAction(amount)
                }
            }
        )
        
        if let index = alert.actions.firstIndex(where: { $0.title == "Done" }) {
            alert.actions[index].isEnabled = false
        }
        
        return alert
    }
}
