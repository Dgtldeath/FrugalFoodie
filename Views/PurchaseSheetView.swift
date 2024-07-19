//
//  PurchaseSheetView.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 6/18/23.
//

import SwiftUI

struct PurchaseSheetView: View {
    @ObservedObject private var storeManager = StoreManager.shared
    
    var body: some View {
        VStack {
            if storeManager.isPremiumUnlocked {
                PremiumFeatureView()
            }
            else {
                Button("Unlock Premium!") {
                    storeManager.purchasePremium()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            storeManager.requestProducts()
        }
    }
}

struct PremiumFeatureView: View {
    var body: some View {
        Text("Premium Feature Unlocked!!!")
    }
}

struct PurchaseSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseSheetView()
    }
}
