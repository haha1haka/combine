//: [Previous](@previous)

import Foundation
import Combine

func example(of name: String, completion: @escaping () -> ()) {
    print("------Example of: \(name)------")
    completion()
    print()
}
var anyCancellable = Set<AnyCancellable>()




//: [Next](@next)
