//
//  TrendsView.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 6/17/23.
//

import SwiftUI
import CoreData
import Charts

struct TrendsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateMoneySpent, order: .forward)]) var spending: FetchedResults<MonthlySpending>
    
    @State private var isPremiumFlag = (DataController().loadPremiumPurchase() == 1 ? true : false)
    var premiumLimit = 12
    var defaultLimit = 3
    
    var body: some View {
        VStack {
            Text("Spending Trends")
                .font(.largeTitle)
            
            if spending.count == 0 {
                emptyDateView()
            }
            else {
                Chart {
                    ForEach(spending.suffix( (isPremiumFlag ? premiumLimit : defaultLimit) )) { item in
                        BarMark (
                            x: .value("Month", DataController().formatMyDate(myDate: item.dateMoneySpent!)),
                            y: .value("Spending", item.totalSpending)
                        )
                        .foregroundStyle(
                            Gradient(colors: [.orange.opacity(0.8), .green.opacity(0.8)])
                        )
                        .cornerRadius(7.0)
                        .annotation(content: {
                            Text("$\(String(format: "%0.0f", item.totalSpending))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        })
                    }
                }
                .frame(height: 350)
            }
            
//            if isPremiumFlag {
//                Text("Premium Unlocked! Showing 12 months of trends")
//                    .font(.caption2)
//                    .foregroundColor(.gray)
//                    .padding()
//            }
//            else {
//                Text("Unlock Premium to show 12 months of trends instead of \(defaultLimit)")
//                    .font(.caption)
//                    .padding()
//            }
            
            AverageMonthlySpendingSummary()
            
            Spacer()
        }
        .onAppear() {
            isPremiumFlag = (DataController().loadPremiumPurchase() == 1 ? true : false)
        }
    }
}

struct emptyDateView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.125))
                .cornerRadius(20.0)
            
            VStack {
                Text("No data yet!\n\nTap \"Spending\" to add data.")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

struct AverageMonthlySpendingSummary: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateMoneySpent, order: .forward)]) var spending: FetchedResults<MonthlySpending>
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.125))
                .cornerRadius(20.0)
            
            Text("Your average monthly spending is:\n\(getAverageMonthlySpending())")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    func getAverageMonthlySpending() -> String {
        let totalSpending = Double(spending.reduce(0) { $0 + $1.totalSpending })
        if totalSpending == 0.0 {
            return "$0/month"
        }
        let averageSpending = totalSpending / Double(spending.count)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        
        if let averageString = formatter.string(from: NSNumber(value: averageSpending)) {
            return "\(averageString) per month"
        } else {
            return "$0/month"
        }
    }
}

struct TrendsView_Previews: PreviewProvider {
    static var previews: some View {
        TrendsView()
    }
}
