//
//  Transaction.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//
//

import CoreData
import Foundation

@objc(Transaction)
public class Transaction: NSManagedObject {

}

extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var date: Date?
    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var type: TransactionType

}

extension Transaction : Identifiable {

}
