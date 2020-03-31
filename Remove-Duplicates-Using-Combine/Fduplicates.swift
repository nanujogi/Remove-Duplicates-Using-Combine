//
//  Fduplicates.swift
//  Remove-Duplicates-Using-Combine
//
//  Created by Nanu Jogi on 31/03/20.
//  Copyright © 2020 Greenleaf Software. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import TimelaneCombine

class Fduplicates: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    // duplicate array with some isbn
    var isbnarray = ["9789393", "9789191", "9789090", "9789292", "9789090", "1234567", "9789090", "9789191", "hello"]
    
    func getduplicates() {
        
        let pub = isbnarray.publisher // make isbnarray as publisher and assign to property pub.
        var duplicates = [String]() // to store duplicates found
        
        for (idx, isbn) in isbnarray.enumerated() {

            let subscription = pub
                .lane("Filter") // using lanetools to debug.
                // using filter operator we pass an predicate, we emit only the data which matches
                .filter { $0 == isbn }
                
                .lane("Collect")
                // this helps us to transform the single value from above filter publisher to array of values. First time we receive "9789393" after collect it will be ["9789393"]
                .collect()
                
                .lane("map")
                // map will transform the data which is Arrays of string ["9789393"] to String value i.e. "9789393"
                .map { data -> String in
                    
                    if data.count > 1 { // if the count is greater then 1 we know its an duplicate string.
                        if let duplicateisbn = data.first { // so we get the first element from data array.
                            return duplicateisbn + " Index : " + String(idx) // and return with Index
                        }
                    }
                    return "" // if not duplicate we send an empty string which is checked in .sink below
            }
                //                .sink(receiveValue: { print(".sink value \($0)")})
                .lane("sink subscriber")
                
                // subscribe to the publisher using .sink
                
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
//                        print("✅ receveid completion type .finished \(completion)")
                        break
                    case .failure(let anError):
//                        print("❌ received completion type .failure: ", anError)
                        break
                    }
                }, receiveValue: { value in
                    // if the value receive is not empty we know its an duplicate string
                    if !value.isEmpty {
                        duplicates.append(value) // save it in duplicates
                        print(".sink() data received \(value)")
                    }
                })
                .store(in: &subscriptions)
            
        }
        
        //        let setarray = Array(Set(duplicates))
        //        print("Duplicates : \(setarray)")
        print("Duplicates : \(duplicates)")
        
    }
}
