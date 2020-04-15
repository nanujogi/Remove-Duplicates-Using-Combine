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
        VStack(spacing: 20) {
            Button(action: {
                self.store.getduplicates()
            }) {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.blue)
                Text("Tap to get duplicates")

            }
            
            Text("myTimer: \(self.store.currentDate)")
                .onAppear {
                    self.store.myTimer()
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            
            Text("get random number")
                .onReceive(self.store.performAsyncActionAsFutureWithParameter(), perform: { (rn) in
                    print("\nrandom number is: \(rn)\n")
                })
                
            .font(.subheadline)
            .foregroundColor(.blue)
            
            Text("remove duplicates using Combine Ext")
                .onAppear {
                    self.store.removeduplicatesCombeinExt()
                    self.store.mystr()
            }
            .foregroundColor(.blue)
            
            VStack {
                List {
                    ForEach(self.store.str, id: \.self) { isbn in
                        Text(isbn)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
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
