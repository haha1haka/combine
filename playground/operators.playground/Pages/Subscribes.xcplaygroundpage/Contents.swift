//: [Previous](@previous)

import Foundation
import Combine

func example(of name: String, completion: @escaping () -> ()) {
    print("------Example of: \(name)------")
    completion()
    print()
}
var anyCancellable = Set<AnyCancellable>()

// MARK: - Subscribsers 3가지) 1)subscribe, 2)sink, 3)assign(to:on:)

/**
 Convenience Subcribes
 - subscribe
 - sink
 - assign(to: on: )
 
 */

example(of: "Subscriber") {
    class BaseSubscriber: Subscriber {
        typealias Input = String
        typealias Faliure = Never
        
        /// publisher가 Subscription주면 호출 됨  --> 바로 request
        func receive(subscription: Subscription) {
            print("구독시작")
            subscription.request(.unlimited)
        }
        
        /** receive(_ input:):  Publisher가 주는 값을 처리
         - Subscribers: subscriber역할을 하는 타입들을 정의 해 둔 곳
         - Demand: subscription을 통해 subscriber가 publisher에게 보낸 request 횟수
         */
        func receive(_ input: String) -> Subscribers.Demand {
            print("Input: \(input)")
            ///Publisher에게 값을 한번 더 달라고 요청          --> .max(1)
            ///Publisher에게 값을 더이상 안줘도 된다고 알림 --> .none
            ///Publisher에게 끝없이 값을 달라고 요청           --> .unlimited
            return .none
        }
        /// subscriber에게 publisher가 정상적으로 또는 오류로 publisher를 완료했음을 알림
        func receive(completion: Subscribers.Completion<Never>) {
            print("완료", completion)
        }
    }


    ["a", "b", "c", "d", "e"]
        .publisher
        .subscribe(BaseSubscriber())
}

example(of: "Sink 직접 만들어서 subscribe로 전달") {
    let strArrayPublisher = ["a", "b", "c"].publisher
    
    let sink = Subscribers.Sink<String, Never>.init(
        receiveCompletion: {
            print("✅\($0)")
        },
        receiveValue: {
            print($0)
        }
    )
    
    strArrayPublisher.subscribe(sink)
}

example(of: "sink매서드 손쉽게 이용") {
    let strArrayPublisher = ["a", "b", "c"].publisher
    
    strArrayPublisher.sink(
        receiveCompletion: {
            print("✅\($0)")
        }, receiveValue: {
            print($0)
        }
    )
}

example(of: "sink 시점 확인", completion: {
    let subject = PassthroughSubject<String, Never>.init()
    
    let sink1 = Subscribers.Sink<String, Never>.init(
        receiveCompletion: {
            print("1번째 ✅ \($0)")
        },
        receiveValue: {
            print("1번째 Value: \($0)")
        }
    )
    let sink2 = Subscribers.Sink<String, Never>.init(
        receiveCompletion: {
            print("2번째 ✅ \($0)")
        },
        receiveValue: {
            print("2번째 Value: \($0)")
        }
    )

    
    subject.subscribe(sink1)
    subject.subscribe(sink2)
    subject.send("Jack")
    
    sink1.cancel()
    
    subject.send("Hue")
    subject.send(completion: .finished)
    
})
//: [Next](@next)
