//: [Previous](@previous)

import Foundation
import Combine


func example(of name: String, completion: @escaping () -> ()) {
    print("------Example of: \(name)------")
    completion()
}

var anyCancellable = Set<AnyCancellable>()
// MARK: - collect
///✅ collect: 개별 value -> array로 변경
/// ㄴ value를 버퍼에 쌓고, completion때 array를 만들어줌
/// ㄴ defualt 는 모두 array로 만드는 것, 버퍼를 지정해주면 버퍼에 맞게 그룹지어 array를 만듦
///⚠️ completion 될때까지 무한정 array를 채울 수 있기 때문에 미모리 관리에 주의
///
example(of: "collect") {
    let numbers = (0...10)
    numbers
        .publisher
        .collect()
        .sink {
            print($0)
        }
}

example(of: "collect2") {
    ["A", "B", "C", "D", "E"]
        .publisher
        .collect(2)
        .sink(receiveCompletion: {print($0, type(of: $0))}, receiveValue: {print($0, type(of: $0))})
        .store(in: &anyCancellable)
}
// MARK: - map
///✅ Map: swift map 이랑 똑같다.
example(of: "Map") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    [123, 4, 56]
        .publisher
        .map { formatter.string(for: NSNumber(integerLiteral: $0)) ?? "" }
        .sink(receiveValue: { print($0) })
        .store(in: &anyCancellable)
}
// MARK: - mapKeyPaths
///✅ Map key paths: keyPath를 통해 바로 매핑
///ㄴ 3개까지 가능
///ㄴ .map { $0.x, $0.y } 이거랑 뭐가 다른지는 모르겠음.
example(of: "MapKeyPaths") {
    
    struct Coordinator {
        var x: Int
        var y: Int
    }
    
    let publisher = PassthroughSubject<Coordinator, Never>()
    publisher
        .map(\.x, \.y)
        .sink(receiveValue: { x, y in
            print("Coordinate at (\(x), \(y))")
        })
        .store(in: &anyCancellable)
    publisher.send(Coordinator(x: 10, y: 10))
    publisher.send(Coordinator(x: -1, y: 2))
}

// MARK: - tryMap
///✅ tryMap
///ㄴ 에러를 확인하면서 mapping이 이루어짐
///ㄴ transform클로저가 오류 발생하면 publish 종료 시킴

example(of: "tryMap") {
    enum NillError: String, Error {
        case cantHandle
    }
    
    func handleNumber(num: Int?) throws -> Int {
        guard let num = num else { throw NillError.cantHandle }
        return num * 2
    }
    
    [1, 2, nil, 3, 4]
        .publisher
        .tryMap { try handleNumber(num: $0) }
        .sink(receiveCompletion: {
            switch $0 {
            case .finished:
                print("finished")
            case .failure(let error):
                print("❌\(error.localizedDescription)")
            }
        }, receiveValue: {
            print($0)
        })
        .store(in: &anyCancellable)
    
}



// MARK: - flatMap

///✅ flatMap:
///ㄴ 새로운 publishers 를 반환
///ㄴ 즉 map이나 , tryMap 처럼 value를 반환하지 않음

example(of: "basic flatMap") {
    var arr = [1,2,3]
    let result = arr
        .map { [$0 * 2, $0 * 3] } // [[2,3], [4,6], [6,9]] //[[Int]]
        //.flatMap { $0 }
    print(result)
}

///요약
///ㄴStruct(publisher) -> Struct.message(Publisher) 구조에서 "Struct 에 publisher"를 달고 flatMap operator를 사용해 message를 subscribe할 수 있음
///ㄴ Observable<Observable<String>> 에서 inner Stream 빼는거랑 그냥 동일
example(of: "flatMap") {
    struct Chatter {
        let name: String
        let message: CurrentValueSubject<String, Never>
        
        init(name: String, message: String) {
            self.name = name
            self.message = CurrentValueSubject(message)
        }
    }
    
    let charlotte = Chatter(name: "Charlotte", message: "Hi I'm Chalotte")
    let james = Chatter(name: "James", message: "Hi I'm James")
    
    let chat = CurrentValueSubject<Chatter, Never>(charlotte)
    
//    chat
//        .sink {
//            print($0.message.value)
//        }
//        .store(in: &anyCancellable)
    
    //charlotte.message.value = "Charlotte: How's it going???"
    
    chat.value = james
    chat.value = charlotte

    chat
        .flatMap { $0.message }
        .sink { print("🟩\($0)") }
        .store(in: &anyCancellable)
    
    chat.value = james
    james.message.value = "메세지가 바뀌었나요?"
    chat.value = charlotte
}



example(of: "flatMap in Network") {
    func search(keyword: String) -> URLSession.DataTaskPublisher {
        let url = URL(string: "https://google-search3.p.rapidapi.com/api/v1/scholar/q=\(keyword)")!
        return URLSession.shared.dataTaskPublisher(for: url)
    }
        
    let searchKeywordSubject = PassthroughSubject<String, Never>()

    searchKeywordSubject
        //.map(search)
        .flatMap(search)
        .sink {
            print("❌\($0)")
        } receiveValue: {
            print("🎃\($0)")
        }.store(in: &anyCancellable)

    searchKeywordSubject.send("ios")
}



























