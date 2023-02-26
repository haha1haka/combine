//: [Previous](@previous)
import Foundation
import Combine

// MARK: - setting
import Foundation
func example(of name: String, completion: @escaping () -> ()) {
    print("------Example of: \(name)------")
    completion()
}
var anyCancellable = Set<AnyCancellable>()

example(of: "NoficationCenter") {
    var mySubscription: AnyCancellable?
    var myNotificationName = Notification.Name("히히")
    var myDefaultPublisher = NotificationCenter.default.publisher(for: myNotificationName)
    mySubscription = myDefaultPublisher
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("완료")
            case .failure(let error):
                print("error: \(error)")
            }
        }, receiveValue: { emittedValue in
            print("emittedValue: \(emittedValue)")
        })
    
    NotificationCenter.default.post(Notification(name: myNotificationName))
    NotificationCenter.default.post(Notification(name: myNotificationName))
    NotificationCenter.default.post(Notification(name: myNotificationName))
    
    ///메모리 상에 등록된 NotificationCenter를 항상 지워줘야됨
    ///이렇게 AnyCancelable과  cancel()매서드를 통해 일일이 해제 시키기도 가능하지만
    ///Set<AnyCancellable> 을 통해 메모리를 한번에 deinit시점에 지워 지도록 할수 있음
    mySubscription?.cancel()
        
}


example(of: "KVO: Key value observing") {
    ///KVO: 키와 값을 계속 옵저빙 한다는 것
    class MyFriend {
        var name = "철수" {
            didSet {
                print("name didSet! : ", name)
            }
        }
    }
    
    var myFriend = MyFriend()
    
    ["영수"]
        .publisher
        .assign(to: \.name, on: myFriend)
}


//: [Next](@next)
