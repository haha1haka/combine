//: [Previous](@previous)
import Foundation
import Combine

// MARK: - setting
func example(of name: String, completion: @escaping () -> ()) {
    print("------Example of: \(name)------")
    completion()
}
var anyCancellable = Set<AnyCancellable>()

// MARK: - Publishers

/**
 Convenience Publishers
 - Futrue
 - Just
 - Defeered
 - Empty
 - Fail
 - Record
 */

example(of: "Just") {
    
    let just = Just("Hello world!")
    
    just
        .sink {
            print("completion: \($0)")
        } receiveValue: {
            print("value --> : \($0)")
        }
}

example(of: "Future") {
    
    let future = Future<Int, Never> { promiss in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            promiss(.success(1))
        }
    }
    
    future
        .sink (receiveCompletion: { print($0) },
               receiveValue: { print($0) })
        .store(in: &anyCancellable)
    
    print("end")
}



//: [Next](@next)
