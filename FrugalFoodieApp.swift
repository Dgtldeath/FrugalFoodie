//
//  FrugalFoodieApp.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 6/14/23.
//

import SwiftUI

@main
struct FrugalFoodieApp: App {
    @State private var dataController = DataController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.context)
        }
    }
}
