//
//  ContentView.swift
//  Remove-Duplicates-Using-Combine
//
//  Created by Nanu Jogi on 31/03/20.
//  Copyright © 2020 Greenleaf Software. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var store = Fduplicates()
    
    @State private var intreceived =  0
    @State private var currentDate = Date()
    
    
    var body: some View {
        VStack {
            Button(action: {
                self.store.getduplicates()
            }) {
                Text("get duplicates")
            }
            
            Text("myTimer: \(self.store.currentDate)")
                .onAppear {
                    self.store.myTimer()
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(20)
            
            Text("get random number")
                .onReceive(self.store.performAsyncActionAsFutureWithParameter(), perform: { (rn) in
                    print("\nrandom number is: \(rn)")
                })
                
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding(20)
            
            /*
             Text("timer variable \(self.intreceived)")
             .onReceive(store.timer) { counter in
             if counter >= 0 {
             print("counter reached 0")
             self.store.subscriptions.removeAll()
             } else {
             self.intreceived = counter
             }
             }
             */
        }
    }
}

