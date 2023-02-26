//: [Previous](@previous)

import Foundation
import Combine
func example(of name: String, completion: @escaping () -> ()) {
    print("------Example of: \(name)------")
    completion()
}
var anyCancellable = Set<AnyCancellable>()


// MARK: - CurrentValueSubject1
///PassthroughSubject와 달리 CurrentValuesubject는 가장 최근에 publish된 element의 버퍼를 유지.
example(of: "CurrentValueSubject") {
    let currentValueSubject = CurrentValueSubject<String, Never>("Jack")
    let subscriber = currentValueSubject.sink { print($0) }
    currentValueSubject.value = "안녕"
    currentValueSubject.send("하이")
}

// MARK: - CurrentValueSubject2
example(of: "CurrentValueSubject 순서 확인") {
    let currentValueSubject = CurrentValueSubject<String, Never>("Jack")
    
    currentValueSubject.sink { print("1번째 \($0)") }
    currentValueSubject.sink { print("2번째 \($0)") }
    currentValueSubject.sink { print("3번째 \($0)") }
    
    currentValueSubject.send("Hue")
    
}

// MARK: - CurrentValueSubject3
example(of: "CurrentValueSubject 구독해제 시점 확인") {
    let currentValueSubject = CurrentValueSubject<String, Never>("Jack")
    
    currentValueSubject.sink(receiveCompletion: { completion in
        print("1번째 ✅ \(completion)")
    }, receiveValue: {
        print("1번째 Value: \($0)")
    })
    .cancel()
    
    currentValueSubject.sink(receiveCompletion: { completion in
        print("2번째 ✅ \(completion)")
    }, receiveValue: {
        print("2번째 Value: \($0)")
    })
    
    
    currentValueSubject.send("Hue")
    currentValueSubject.send(completion: .finished)
    currentValueSubject.send("Hue")
}


// MARK: - PassthroughSubject1
///downstream subscribers에게 element를 brodcasts하는 subject이다.
///CurrentValueSubject와 달리, PassthroughSubject에는 가장 최근에 publish된 element의 초기값 또는 버퍼가 없음
example(of: "PassthroughSubject") {
    let passthroughSubject = PassthroughSubject<String, Never>()
    
    passthroughSubject.sink(
        receiveValue: {
            print($0)
        }
    )
    
    passthroughSubject.send("안녕")
}

// MARK: - PassthroughSubject2
example(of: "PassthroughSubject 초기값 시점 확인") {
    let passthroughSubject = PassthroughSubject<String, Never>()
    
    passthroughSubject.sink(
        receiveCompletion: { completion in
            print("1번째 ✅ \(completion)")
        },
        receiveValue: {
            print("1번째 Value: \($0)")
        }
    )
    
    passthroughSubject.send("Jack")
    
    passthroughSubject.sink(
        receiveCompletion: { completion in
            print("2번째 ✅ \(completion)")
        },
        receiveValue: {
            print("2번째 Value: \($0)")
        }
    )
    
    passthroughSubject.send("Hue")
}


//: [Next](@next)
