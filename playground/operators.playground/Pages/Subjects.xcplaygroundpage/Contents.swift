//: [Previous](@previous)

import Foundation
import Combine
func example(of name: String, completion: @escaping () -> ()) {
    print("------Example of: \(name)------")
    completion()
}
var anyCancellable = Set<AnyCancellable>()

// MARK: - CurrentValueSubject
///PassthroughSubject와 달리 CurrentValuesubject는 가장 최근에 publish된 element의 버퍼를 유지.
example(of: "CurrentValueSubject") {
    let currentValueSubject = CurrentValueSubject<String, Never>("Jack")
    let subscriber = currentValueSubject.sink { print($0) }
    currentValueSubject.value = "안녕"
    currentValueSubject.send("하이")
}



// MARK: - PassthroughSubject
///downstream subscribers에게 element를 brodcasts하는 subject이다.
///CurrentValueSubject와 달리, PassthroughSubject에는 가장 최근에 publish된 element의 초기값 또는 버퍼가 없음
example(of: "PassthroughSubject") {
    let passthroughSubject = PassthroughSubject<String, Never>()
    let subscriber = passthroughSubject.sink(receiveValue: { print($0) })
    passthroughSubject.send("안녕")
}


//: [Next](@next)
