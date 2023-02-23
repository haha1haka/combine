//: [Previous](@previous)
import Foundation
import Combine

// MARK: - setting
func example(of name: String, completion: @escaping () -> ()) {
    print("------Example of: \(name)------")
    completion()
}
var anyCancellable = Set<AnyCancellable>()

/**
 Convenience Publishers
 - Futrue
 - Just
 - Defeered
 - Empty
 - Fail
 - Record
 */
/**
 Convenience Subcribes
 - subscribe
 - sink
 - assign(to: on: )
 
 */

// MARK: - Publishers
// MARK: - Just
example(of: "Just") {
    
    let just = Just("Hello world!")
    
    just
        .sink {
            print("completion: \($0)")
        } receiveValue: {
            print("🟩 value: \($0)")
        }
    
}



// MARK: - Subscribsers 3가지) 1)subscribe, 2)sink, 3)assign(to:on:)

// MARK: - subscribe

class BaseSubscriber: Subscriber {
    typealias Input = String
    typealias Faliure = Never
    
    /// subscriber에게 publisher를 성공적으로 구독했음을 알림 + item 을 요청
    /// unlimited:
    func receive(subscription: Subscription) {
        print("구독시작")
        subscription.request(.unlimited)
    }
    /// subscriber에게 publisher가 element를 생성했음을 알림
    func receive(_ input: String) -> Subscribers.Demand {
        print("Input: \(input)")
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
    




















































































//: [Next](@next)
