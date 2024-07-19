//
//  AddMonthlySpending.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 6/17/23.
//

import SwiftUI
import CoreData

struct AddMonthlySpending: View {
    @State private var successMonthlyBudgetSaved = false
    @State private var monthlyBudget: Double = 600
    @State private var showingAddSpendingSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section ("Set Monthly Budget") {
                    VStack {
                        Text("Current Monthly Budget: $\( String(format: "%0.0f", monthlyBudget))")
                            .multilineTextAlignment(.leading)
                        
                        Slider(value: $monthlyBudget, in: 100...1200, step: 50) // Adjust the range and step as needed
                            .padding(.horizontal)
                        
                        Divider()
                        
                        Button("Update Budget") {
                            DataController().saveMonthlyBudget(value: monthlyBudget)
                            withAnimation (.easeInOut) {
                                successMonthlyBudgetSaved.toggle()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation (.easeInOut) {
                                    successMonthlyBudgetSaved.toggle()
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.headline)
                        .padding(.top)
                        .clipShape(Capsule())
                        
                        if (successMonthlyBudgetSaved) {
                            ZStack {
                                Rectangle()
                                    .fill(.green)
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(10)
                                
                                Text("Saved!")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                SpendingHistoryData()
                
            }   // form
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSpendingSheet.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showingAddSpendingSheet) {
                        AddMonthlySpendingSection()
                    }
                }
            }
            .navigationTitle("Budget & Spending")
            .listRowSeparator(.hidden)
            .onAppear() {
                monthlyBudget = DataController().loadMonthlyBudget()
            }
        }
    }   // body
    
    
}

struct SpendingHistoryData: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateMoneySpent, order: .reverse)]) var spending: FetchedResults<MonthlySpending>
    
    @State private var editSheetShowing = false
    
    var body: some View {
        
        Section ("Spending History Data") {
            if spending.count == 0 {
                Text("No date yet")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            else {
                List {
                    ForEach(spending, id: \.id) { item in
                        
                        NavigationLink(destination: EditSpendingView(spending: item)) {
                            VStack {
                                Text("\(DataController().formatMyDate(myDate: item.dateMoneySpent!))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 1.0)
                                
                                Text("$\(String(format: "%0.0f", item.totalSpending))")
                                    .font(.title3)
                            }
                        }
                        
                    }
                    .onDelete(perform: deleteSpendingItem)
                }
            }
        }
    }
    
    func deleteSpendingItem(offsets: IndexSet) {
        withAnimation {
            offsets.map { spending[$0] }.forEach(managedObjectContext.delete)
            
            DataController().save(context: managedObjectContext)
        }
    }
}

struct EditSpendingView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    var spending: FetchedResults<MonthlySpending>.Element
    @State private var updatedMonthlySpending: Double = 0.0
    
    var body: some View {
        
        Form {
            Section(header: Text("Update Monthly Spending")) {
                TextField("Enter monthly spending", value: $updatedMonthlySpending, format: .number)
                    .keyboardType(.decimalPad)
            }
            
            Button(action: {
                DataController().editMoneySpent(spending: spending, totalSpent: updatedMonthlySpending, context: managedObjectContext)
                
                dismiss()
            }, label: {
                HStack {
                    Spacer()
                    Text("Save")
                    Spacer()
                }
            })
        }
        .onAppear() {
            updatedMonthlySpending = spending.totalSpending
        }
    }
}

struct AddMonthlySpendingSection: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var amountSpent: Double = 0
    @State private var dateMoneyWasSpent: Date = Date()
    @State private var successAddMonthlySpending = false
    @State private var isSaveButtonEnabled = false
    @State private var dataForMonthExists = false
    @State private var showAlertAmountIsZero = true
    
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.dateMoneySpent, order: .reverse)]) var spending: FetchedResults<MonthlySpending>
    
    var body: some View {
        NavigationStack {
            Section {
                VStack {
                    Text("Total Spent $\( String(format: "%0.0f", amountSpent))")
                        .padding()
                        .padding(.bottom, 20)
                        .font(.title)
                    
                    
                    ZStack {
                        Rectangle()
                            .fill(.gray.opacity(0.08))
                            .cornerRadius(20)
                        
                        VStack {
                            Text("Select Amount Spent")
                            
                            Slider(value: $amountSpent, in: 0...1200, step: 5) // Adjust the range and step as needed
                                .padding(.horizontal)
                            
                            VStack {
                                Text("Fine Adjustment")
                                    .padding(0)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Stepper("Fine Adjustment:", value: $amountSpent, in: 0...1200, step: 1)
                                    .padding(0)
                                    .labelsHidden()
                                    .onChange(of: amountSpent, perform: { _ in
                                        updateSaveButtonState()
                                    })
                                
                                Divider()
                                    .padding(.vertical)
                                
                                Text("Selected Month: \(DataController().formatMyDate(myDate: dateMoneyWasSpent))")
                                
                                DatePicker("Date Money Was Spent", selection: $dateMoneyWasSpent, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .onChange(of: dateMoneyWasSpent, perform: { _ in
                                        updateSaveButtonState()
                                    })
                                
                                if dataForMonthExists {
                                    ZStack {
                                        Rectangle()
                                            .fill(.yellow)
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(10)
                                        
                                        Text("Spending amount already saved for: \(DataController().formatMyDate(myDate: dateMoneyWasSpent))")
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }
                                    .frame(height: 30)
                                    .padding()
                                }
                                
                                if showAlertAmountIsZero {
                                    ZStack {
                                        Rectangle()
                                            .fill(.yellow)
                                            .frame(maxWidth: .infinity)
                                            .cornerRadius(10)
                                        
                                        Text("Enter amount greater than 0")
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }
                                    .frame(height: 30)
                                    .padding()
                                }
                                    
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .padding()
                    .frame(height: 300)
                    
                    if (successAddMonthlySpending) {
                        ZStack {
                            Rectangle()
                                .fill(.green)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                            
                            Text("Saved!")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .frame(height: 30)
                        .padding()
                    }
                    
                    Spacer()
                    
                }   // vstack
            }  // section
            .listRowSeparator(.visible)
            .padding(.bottom)
            .navigationTitle("Add Expense")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Save and adjust buttons
                    Button(action: {
                        DataController().addMoneySpent(totalSpent: amountSpent, dateMoneySpent: dateMoneyWasSpent, context: managedObjectContext)
                        withAnimation (.easeInOut) {
                            successAddMonthlySpending.toggle()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation (.easeInOut) {
                                successAddMonthlySpending.toggle()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        
                        if isSaveButtonEnabled {
                            Text("Save")
                                .padding()
                                .frame(height: 30)
                                .font(.headline)
                                .foregroundColor(.white)
                                .background(.blue)
                                .clipShape(Capsule())
                        }
                        else {
                            Text("Save")
                                .frame(height: 30)
                                .font(.headline)
                        }
                    }
                    .disabled(!isSaveButtonEnabled)
                }
            }
            .onAppear() {
                updateSaveButtonState()
            }
        }
    }
    
    private func updateSaveButtonState() {
        let selectedMonth = DataController().formatMyDate(myDate: dateMoneyWasSpent)
        var savedMonths: [String] = []
        for item in spending {
            let spendingMonth = DataController().formatMyDate(myDate: item.dateMoneySpent!)
            savedMonths.append(spendingMonth)
        }
        
        if amountSpent > 0 {
            showAlertAmountIsZero = false
            if savedMonths.contains(selectedMonth) {
                dataForMonthExists = true
                isSaveButtonEnabled = false
            }
            else {
                isSaveButtonEnabled = true
                dataForMonthExists = false
            }
        }
        else {
            showAlertAmountIsZero = true
            isSaveButtonEnabled = false
        }
    }
}

struct AddMonthlySpending_Previews: PreviewProvider {
    static var previews: some View {
        AddMonthlySpending()
    }
}
