//
//  PremiumFeaturesView.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 6/18/23.
//

import SwiftUI

struct PremiumFeaturesView: View {
    @ObservedObject private var storeManager = StoreManager.shared
    @State public var isPremiumFlag = DataController().loadPremiumPurchase()
    
    var body: some View {
        if isPremiumFlag == 1 || storeManager.isPremiumUnlocked {
            UnlockedView(items: [PantryItems]())
        }
        else {
            LockedAndMustPurchaseView()
        }
    }
}



struct LockedAndMustPurchaseView: View {
    @ObservedObject private var storeManager = StoreManager.shared
    @State private var showStoreSheet = false
    
    var body: some View {
        VStack {
            
            if storeManager.isPremiumUnlocked {
                Text("Premium is unlocked??!")
                    .font(.title)
            }
            
            Text("Get Premium and Unlock Everything!")
                .font(.title2)
                .padding()
            
            VStack (alignment: .leading) {
                Text("Trends out to 1 year!")
                    .padding()
                
                Text("Gourmet Grocer - Smart Shopping List created based on your budget to further stretch your food budget.")
                    .padding()
                
                Text("Frugal Fitness Fuel - Access premium meal plans and nutrition advice tailored to fitness enthusiasts on a budget.")
                    .padding()
            }
            
            Button("Get Premium") {
                print("opening store")
                storeManager.purchasePremium()
            }
            .buttonStyle(.borderedProminent)
            .onAppear() {
                storeManager.requestProducts()
            }
        }
        .navigationTitle("Unlock Premium to gain access!")
    }
}

struct PantryItems: Identifiable {
    var id: UUID = UUID()
    var itemName: String
    var price: Double
}

struct UnlockedView: View {
    @State var items: [PantryItems]
    
    var body: some View {
        NavigationView {
            VStack {
                
                List {
                    ForEach(items) { item in
                        HStack {
                            Text(item.itemName)
                            
                            Spacer()
                            
                            Text("\(item.price)")
                                .font(.callout)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Premium Pantry!")
        }
        .onAppear() {
            loadItems()
        }
    }
    
    func loadItems() {
        items.append(PantryItems(itemName: "Chicken Sausage", price: 4.29))
        items.append(PantryItems(itemName: "Organic Red Potatoes", price: 3.39))
    }
}

struct PremiumFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumFeaturesView()
    }
}
