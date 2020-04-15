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
import os.log
import CombineExt

class Fduplicates: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    var counter = 0
    
    @Published var currentDate = Date()
    @Published var str = [String]()
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    private let log = OSLog(subsystem: subsystem, category: "fduplicates")
    
    // duplicate array with some isbn
    var isbnarray = ["9789393", "9789191", "9789090", "9789292", "9789090", "1234567", "9789090", "9789191", "hello"]
    
    func getduplicates() {
        
        os_log("%{public}@", log: log, type: .info, #function)
        
        let pub = isbnarray.publisher // make isbnarray as publisher and assign to property pub.
        var duplicates = [String]() // to store duplicates found
        
        for (idx, isbn) in isbnarray.enumerated() {
            
            let subscription = pub
                .lane("Filter") // using Timelanetools to debug.
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
    
    let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .scan(-5) { mycounter, _ in
            return mycounter + 1  }
    //        .eraseToAnyPublisher()
    
    func myTimer() {
        
        /* For better understanding visit below.         https://www.apeth.com/UnderstandingCombine/publishers/publisherstimer.html
         */
        
        self.subscriptions.first?.cancel()
        // Creating an Timer Publisher
        let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
        
        // creating a pipeline to subscribe to our timerPublisher which will emit Date & will Never fail.
        let timerPipeline = Subscribers.Sink<Date,Never>(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("✅ receveid completion type .finished \(completion)")
                break
            case .failure(let anError):
                print("❌ received completion type .failure: ", anError)
                break
            }
        }, receiveValue: { value in
            self.currentDate = value // Save it in an @Published variable
            self.counter += 1 // Our counter how many times we need to emit the data from publisher
            if self.counter <= 5 {
                print(".sink() data received \(value)") // print the value received on console
            } else {
                closepipeline() // Once we receive all the required emitted value we close the pipeline
            }
        })
        
        timerPublisher.subscribe(timerPipeline) // subscriber to the publisher
        timerPublisher.connect() // start emitting the values.
            .store(in: &subscriptions) // we store it in our Set of AnyCancellable.
        
        func closepipeline() {
            print("After getting 5 dates we are now closing the pipeline.")
            subscriptions.removeAll() //
        }
    }
    
    /// MARK: Apple Codes
    /*
     https://developer.apple.com/documentation/combine/using_combine_for_your_app_s_asynchronous_code
     */
    func performAsyncActionAsFutureWithParameter() -> Future <Int, Never> {
        // Future takes one parameter called a promise
        // The promise function itself is, in face a completion function.
        return Future() { promise in
            DispatchQueue.main.asyncAfter(deadline:.now() + 2) {
                let rn = Int.random(in: 1...10)
                promise(Result.success(rn)) // promise function itself is in fact a completion function. This is the signal to the Future that it is time to publish.
                
                // promise function takes one parameter: a Result
                
            }
        }
    }
    
    /*
         var isbnarray = ["9789393", "9789191", "9789090", "9789292", "9789090", "1234567", "9789090", "9789191", "hello"]
     */
    
    // Code from CombineExt below.
    
    func removeduplicatesCombeinExt() {
        let pub = isbnarray.publisher
//
//            .removeDuplicates(by: { (first, second) -> Bool in
//                print("first: \(first) second: \(second)")
//                print("\(first != second)")
//                return first != second
//            })
////
//            .removeAllDuplicates(by: { (prev, next) -> Bool in
//                print("first: \(prev) second: \(next)")
//                print("\(prev == next)")
//                return prev == next
//
//            })
            .removeAllDuplicates2()
            .collect()
            .receive(on: DispatchQueue.main) // Necessary or it will crash.
        let subscription = pub
            .sink { value in
                print("\nCombineExt removeAllDuplicates:  \(value)\n")
                self.str = value
        }
        .store(in: &subscriptions)
    }
    
    func mystr() {
        let subscription = self.$str
            .sink { print ("Value received is \($0)\n") }
            .store(in: &subscriptions)
    }
}

public extension Publisher where Output: Hashable {
    /// De-duplicates _all_ published value events, as opposed
    /// to pairwise with `Publisher.removeDuplicates`.
    ///
    /// - note: It’s important to note that this operator stores all emitted values
    ///         in an in-memory `Set`. So, use this operator with caution, when handling publishers
    ///         that emit a large number of unique value events.
    ///
    /// - returns: A publisher that consumes duplicate values across all previous emissions from upstream.
    func removeAllDuplicates2() -> Publishers.Filter<Self> {
        var seen = Set<Output>()
        return filter { incoming in
            seen.insert(incoming).inserted }
    }
}


