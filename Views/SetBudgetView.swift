//
//  SetBudgetView.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 6/17/23.
//

import SwiftUI

struct SetBudgetView: View {
    
    // Variables for tracking user input
    @State private var monthlyBudget: Double = 600
    @State private var amountSpent: Double = 10
    
    
    var body: some View {
        Form {
            
            Section("Set Monthly Budget", content: {
                VStack {
                    VStack {
                        Text("Set Monthly Budget")
                        
                        Slider(value: $monthlyBudget, in: 50...1000, step: 50) // Adjust the range and step as needed
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Monthly Budget")
                        Text("$\( String(format: "%0.0f", monthlyBudget))")
                    }
                    
                    
                    
                    Spacer()
                    // Save and adjust buttons
                    Button(action: {
                        
                    }) {
                        Text("Save Monthy Budget")
                            .font(.title3)
                            .padding(7)
                    }
                    .clipShape(Capsule())
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }   // vstack
            })
            .padding()
        }   // form
    }   // body
}   // view

struct SetBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        SetBudgetView()
    }
}
