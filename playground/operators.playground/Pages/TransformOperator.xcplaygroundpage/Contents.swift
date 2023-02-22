//: [Previous](@previous)

import Foundation
import Combine


func example(of name: String, completion: @escaping () -> ()) {
    print("------Example of: \(name)------")
    completion()
}
var anyCancellable = Set<AnyCancellable>()

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





///✅ flatMap:
///ㄴ 새로운 publishers 를 반환한다!!
///ㄴ 즉 map이나 , tryMap 처럼 value를 반환하지 않음
///

example(of: "flatMap") {
    struct Cat {
        let name: CurrentValueSubject<String, Never>
    }
    let catA = Cat(name: .init("Felix"))
    let catB = Cat(name: .init("James"))
    let catC = Cat(name: .init("Dochoi"))

    let subject = PassthroughSubject<Cat, Never>()
    
    subject
        .flatMap({ $0.name })
        .sink(receiveValue: {print($0)})
    
    subject.send(catA)
    subject.send(catB)
    subject.send(catC)
    
    catB.name.send("Jack")
    
}

example(of: "flatMap2") {
    
    struct WeatherStation {
        public let stationID: String
    }
    
    var weatherPublisher = PassthroughSubject<WeatherStation, URLError>()
    
    weatherPublisher.flatMap { station -> URLSession.DataTaskPublisher in
        let url = URL(string:"https://weatherapi.example.com/stations/\(station.stationID)/observations/latest")!
        return URLSession.shared.dataTaskPublisher(for: url)
    }
    .sink(
        receiveCompletion: { completion in
            // Handle publisher completion (normal or error).
            print(completion)
        },
        receiveValue: {
            // Process the received data.
            print($0.data)
        }
    )
    .store(in: &anyCancellable)
    
    weatherPublisher.send(WeatherStation(stationID: "KSFO")) // San Francisco, CA
    weatherPublisher.send(WeatherStation(stationID: "EGLC")) // London, UK
    weatherPublisher.send(WeatherStation(stationID: "ZBBB")) // Beijing, CN
}





//: [Next](@next)
