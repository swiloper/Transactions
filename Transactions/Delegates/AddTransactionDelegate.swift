//
//  AddTransactionDelegate.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 18.03.2024.
//

import Foundation

/// Transfers data to create a new transaction between controllers.
protocol AddTransactionDelegate: AnyObject {
    func addTransaction(amount: Double, type: TransactionType, category: ExpenseCategory?)
}
