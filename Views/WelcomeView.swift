//
//  WelcomeView.swift
//  FrugalFoodie
//
//  Created by Adam Gumm on 7/4/23.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            LinearGradient(gradient:
                            Gradient(colors: [.blue.opacity(0.8), .green.opacity(0.8), .orange.opacity(0.8), .indigo.opacity(0.8)]),  startPoint: .topLeading, endPoint: .bottomTrailing)
        
            VStack {
                Spacer()
                
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .frame(height: 520)
                    
                    VStack {
                        Text("Thank you for downloading FrugalFoodie!")
                            .font(.title2)
                            .padding(0)
                            .offset(y: -20)
                        
                        Text("It's easier to stay on budget by going to the store several times per week and knowing how much you can spend during each visit versus one larger shopping. \n\n" +
                             "How to use FrugalFoodie: Whether you use your titanium Apple Card or another payment type, simply track your total food expenditures each month. You can update monthly totals as your spending increases each week.\n\n" +
                             "The dashboard breaks down your daily spending, weekly spending, remaining budget and total amount spent on food. \n\n" +
                             "Please provide any feedback in the\nApple App Store!")
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 0)
                }
                
                Button(action: {dismiss()}, label: {
                    Text("Done")
                        .foregroundColor(.blue.opacity(0.8))
                        .padding()
                        .background(.white.opacity(0.75))
                        .cornerRadius(20)
                })
                
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
