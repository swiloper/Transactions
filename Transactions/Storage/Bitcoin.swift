//
//  Bitcoin.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 18.03.2024.
//
//

import Foundation
import CoreData

@objc(Bitcoin)
public class Bitcoin: NSManagedObject {

}

extension Bitcoin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bitcoin> {
        return NSFetchRequest<Bitcoin>(entityName: "Bitcoin")
    }

    @NSManaged public var balance: Double
    @NSManaged public var rate: Double
    @NSManaged public var lastUpdate: Date?

}

extension Bitcoin : Identifiable {

}
