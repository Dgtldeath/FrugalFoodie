//
//  ContentView.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 6/14/23.
//

import SwiftUI
import CoreData

extension View {
    func glow(color: Color, radius: CGFloat) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(color, lineWidth: 3)
                .blur(radius: radius)
                .opacity(0.9)
        )
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateMoneySpent, order: .reverse)]) var spending: FetchedResults<MonthlySpending>
    
    // Variables for tracking user input
    @State private var monthlyBudget: Double = 600.0
    @State private var amountSpent: Int = 0
    
    @State private var showWelcomeSheet = false
    
    var body: some View {
        TabView {
            VStack {
                Text("Frugal Foodie")
                    .font(.system(size: 50))
                    .multilineTextAlignment(.leading)
                
                HStack {
                    
                    Spacer()
                    
                    Text("Current Monthly Budget: $\( String(format: "%0.0f", monthlyBudget))")
                        .font(.callout)
                        .foregroundColor(.gray)
                    
                    Spacer()
                     
                    Button(action: {
                        showWelcomeSheet.toggle()
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                    }
                    .foregroundColor(.gray.opacity(0.5))
                    .sheet(isPresented: $showWelcomeSheet, content: {
                        WelcomeView()
                    })
                }
                .padding(.horizontal)
                
                ScrollView (.vertical) {
                    VStack {
                        
                        // third Square Widget
                        coloredWidgetSquare(
                            amountText: String(getNewDailySpendingAdjustedBudget()) + "/day",
                            widgetColor: .blue,
                            captionTitle: "Daily spending to hit your monthly budget"
                        )
                        
                        coloredWidgetSquare(
                            amountText: String(getNewWeeklyAdjustedBudget()) + "/week",
                            widgetColor: .green,
                            captionTitle: "Weekly spending to hit your monthly budget")
                        
                        coloredWidgetSquare(
                            amountText: String(format: "%0.2f", (monthlyBudget - getAmountSpentCurrentMonth())),
                            widgetColor: .orange,
                            captionTitle: "Remaining Budget"
                        )
                        
                        coloredWidgetSquare(
                            amountText: String(format: "%0.2f", calculateTotalAmount()),
                            widgetColor: .indigo,
                            captionTitle: "Total Amount Spent on Food"
                        )
                    }
                    .padding(.horizontal, 50.0)
                    .padding(.vertical, 25.0)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    monthlyBudget = DataController().loadMonthlyBudget()
                }
                
                Spacer()
            }
            .onAppear() {
                monthlyBudget = DataController().loadMonthlyBudget()
            }
            
            .tabItem {
                Label("Budget", systemImage: "dollarsign.circle")
            }
            
            // Second View: Trends
            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.bar.fill")
                }
            
            // Third View: Monthly Spending Input and Adjustment
            AddMonthlySpending()
                .tabItem {
                    Label("Spending", systemImage: "square.and.pencil")
                }
            
//            PremiumFeaturesView()
//                .tabItem {
//                    Label("Pantry", systemImage: "star.fill")
//                }
        }
    }
    
    private func calculateTotalAmount() -> Double {
        let totalAmount = spending.reduce(0) { $0 + $1.totalSpending }
        return totalAmount
    }
    
    private func getAmountSpentCurrentMonth() -> Double {
        let currentMonth = DataController().formatMyDate(myDate: Date())
        var currentMonthSpending = 0.0
        
        for item in spending {
            let spendingMonth = DataController().formatMyDate(myDate: item.dateMoneySpent!)
            if (spendingMonth == currentMonth) {
                currentMonthSpending = item.totalSpending
            }
        }
        
        return currentMonthSpending
    }
    
    func getDaysInMonth() -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let numberOfDaysInMonth = range.count

        return numberOfDaysInMonth
    }
    
    func calculateRemainingDaysInMonth() -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: currentDate)
        
        let remainingDays = getDaysInMonth() - currentDay
        
        return remainingDays
    }
    
    func getNewDailySpendingAdjustedBudget() -> Int {
        
        let currentMonth = DataController().formatMyDate(myDate: Date())
        var currentMonthSpending = 0.0
        for item in spending {
            let spendingMonth = DataController().formatMyDate(myDate: item.dateMoneySpent!)
            if (spendingMonth == currentMonth) {
                currentMonthSpending = item.totalSpending
                if(currentMonthSpending > monthlyBudget) {  // over budget!
                    return 0
                }
                else {  // under budget
                    let budgetDifferece = monthlyBudget - currentMonthSpending
                    var returning = Int(budgetDifferece)
                     
                    if calculateRemainingDaysInMonth() > 1 {
                        returning = Int(budgetDifferece) / calculateRemainingDaysInMonth()
                    }
                    
                    return returning
                }
            }
        }
        
        // if they haven't spent any money
        if currentMonthSpending == 0.0 {
            return Int(monthlyBudget) / calculateRemainingDaysInMonth()
        }
        
        return 0
    }
    
    func getNewWeeklyAdjustedBudget() -> Int {
        let dayMultiplier = 7
        let daysLeft = calculateRemainingDaysInMonth()
        return getNewDailySpendingAdjustedBudget() * (daysLeft < dayMultiplier ? daysLeft : dayMultiplier)
    }
}

struct coloredWidgetSquare: View {
    var amountText: String = ""
    var widgetColor: Color = .indigo
    var captionTitle: String = ""
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(widgetColor.opacity(0.8))
                .frame(width: 270, height: 150)
                .cornerRadius(20)
                .padding()
                .glow(color: widgetColor, radius: 20)
                .shadow(color: widgetColor, radius: 10, x: 0, y: 0)
            
            VStack (alignment: .center) {
                Text("$\( amountText )")
                    .font(.title)
                    .padding(.bottom)
                    .foregroundColor(.white)
                
                Text(captionTitle)
                    .font(.caption)
                    .foregroundColor(.white)
                    
            }
            .padding()
        }
        .frame(width: 270)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, DataController.preview.container.viewContext)
//    }
//}
