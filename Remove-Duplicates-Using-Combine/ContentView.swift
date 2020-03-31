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
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                self.store.getduplicates()
        }
    }
}
