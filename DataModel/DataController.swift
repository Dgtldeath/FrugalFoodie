//
//  DataController.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 6/17/23.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FrugalFoodie")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
        
    var context: NSManagedObjectContext {
        return Self.persistentContainer.viewContext
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data saved!!!")
        } catch {
            // Handle the error
            print("Could not save data")
        }
    }
    
    func addMoneySpent(totalSpent: Double, dateMoneySpent: Date, context: NSManagedObjectContext) {
        let budget = MonthlySpending(context: context)
        budget.id = UUID()
        budget.dateMoneySpent = dateMoneySpent
        budget.totalSpending = totalSpent
        
        save(context: context)
    }
    
    func editMoneySpent(spending: MonthlySpending, totalSpent: Double, context: NSManagedObjectContext) {
        spending.totalSpending = totalSpent
        save(context: context)
    }
//
//    func editMoneySpent(monthlySpendingID: UUID, totalSpent: Double, context: NSManagedObjectContext) {
//        let fetchRequest: NSFetchRequest<MonthlySpending> = MonthlySpending.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id == %@", monthlySpendingID as CVarArg)
//
//        if let monthlySpending = try? context.fetch(fetchRequest).first {
//            monthlySpending.totalSpending = totalSpent
//            save(context: context)
//        }
//    }
    
    func formatMyDate(myDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        return "\(dateFormatter.string(from: myDate))"
    }
    
    // * Premium Purchase * //
    func savePremiumPurchase() {
        UserDefaults.standard.set(1, forKey: "didPurchasePremium")
    }
    
    func loadPremiumPurchase() -> Int {
        //let defaultValue = (UserDefaults.standard.integer(forKey: "didPurchasePremium") == 0 ? 0 : UserDefaults.standard.integer(forKey: "didPurchasePremium"))
        let defaultValue = 0
        
        if let didPurchasePremium = UserDefaults.standard.integer(forKey: "didPurchasePremium") as? Int {
            return didPurchasePremium
        } else {
            return defaultValue
        }
    }
    
    // * Budget * //
    func saveMonthlyBudget(value: Double) {
        UserDefaults.standard.set(value, forKey: "MonthlyBudget")
    }

    func loadMonthlyBudget() -> Double {
        let defaultValue: Double = 600.0
            
        if let monthlyBudget = UserDefaults.standard.double(forKey: "MonthlyBudget") as? Double {
            return monthlyBudget
        } else {
            return defaultValue
        }
    }
}
