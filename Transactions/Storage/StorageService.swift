//
//  StorageService.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 18.03.2024.
//

import Foundation
import CoreData

final class StorageService {
    
    static let shared = StorageService()
    
    // MARK: - Init
    
    private init() {
        // Empty.
    }
    
    // MARK: - PersistentContainer
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Transactions")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - SaveContext
    
    func saveContext(failure: (Error) -> Void, success: () -> Void = {}) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                success()
            } catch let error {
                failure(error)
            }
        }
    }
}
