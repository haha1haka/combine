# Combine 

* [combine이란](https://github.com/haha1haka/combine#combine-1)
* [Publisher](https://github.com/haha1haka/combine#publishers)
* [Subscribers](https://github.com/haha1haka/combine#subscribers)
* [Subscriptions](https://github.com/haha1haka/combine#subscribers)
* [Subject](https://github.com/haha1haka/combine#subject)

  ​    

    

<br/>

## Combine
* 이벤트 처리 코드를 중앙 집중화 
* 중첩된 closures 및 콜백과 같은 까다로운 기술을 제거하여 코드를 읽고 유지보수 하기 쉽게 만든다.
* Timer, NotificationCenter, URLSession 통합관리



<br/>

## Publishers

<img width="481" alt="스크린샷 2023-02-27 01 39 52" src="https://user-images.githubusercontent.com/106936018/221423894-3c86f27f-1243-4497-962b-2d6aa978b58f.png">



* Observable 역할 (차이점은 값과 에러타입을 같이 보냄)
* protocol임
* `Output` `Failure` `receive(subscriber:)` 구현 해야함
    * `Output`
        * Publisher가 생성할 수 있는 값의 타입
    * `Failure`
        * Publisjer가 생성할 수 있는 Error 타입
    * `receive(subscriber:)`
        * Publisher 자신을 subscribe를 subscriber를 받음
        * 즉, 자신이 누구와 구독하고 있는지 확정 짓는 매서드
        * 직접 호출하지않고, `subscribe()` 매서드 호출을 하고 receice실행 -> 이로써, Publisher에게 Subscriber누군지 확정

* 종류
    * Deferred
    * empty
    * Fail
    * Future
    * Just
    * Record



### Just

<img width="463" alt="스크린샷 2023-02-27 01 40 00" src="https://user-images.githubusercontent.com/106936018/221423899-7e1b561f-5a2c-49d4-a248-bb6e9b0ac7b3.png">

* struct임
* 값을 한번 뱉고 finish 이벤트 보냄
* Failure 정의 따로 안해줘도 됨 --> 내부에 Never가 default로 구현 되어 있음

### Future

<img width="479" alt="스크린샷 2023-02-27 01 40 07" src="https://user-images.githubusercontent.com/106936018/221423902-aba0817e-359c-47fc-8301-6f493460e62b.png">

* class임 --> (비동기 작동할 때 `상태저장동작`을 한번 저장 해야해서 class 로 구현한듯)
* 말그대로, 아직 일어나지 않은 미래를 의미 --> async 한 처리에 유용 하다는 것 
* 비동기 작업을 완료하고 promise 클로저에 success, failure 를 태워 보냄
* 네트워킹 모듈을 구성할시에는 `dataTaskPublisher`를 쓰고, 모듈을 호출 할시 비동기 처리는 `Future`가 적당 할듯 싶다 (모듈에서 Future를 이용해서 비동기처리를 한번더 Future에게 알려서 처리하는게 굳이?라는 생각 + Rx의 Single과는 다르다고 생각)

> https://stackoverflow.com/questions/60428303/convert-urlsession-datataskpublisher-to-future-publisher

```swift
func fetchBearList() -> AnyPublisher<[Bear], URLError> {
    return Future<[Bear], URLError> { promiss in
        NetworkService.shared.getAPI()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                guard case .failure(let error) = $0 else { return }
                print(error.localizedDescription)
            }, receiveValue: { data in
                bearList.send(data)
            })
            .store(in: &anyCancellable)
    }.eraseToAnyPublisher()
}
```



### AnyPublisher

<img width="475" alt="스크린샷 2023-02-27 01 42 05" src="https://user-images.githubusercontent.com/106936018/221423998-754c5204-85e4-495f-84f2-6baada1625d3.png">

* struct임
* Publisher타입만 해도 여러개인데 `eraseToAnyPublisher`를 통해 `AnyPublisher`로 한번더 래핑을 해버림 --> 따라서 여러타입을 일일이 대응 안해줘도됨

### Fail

<img width="471" alt="스크린샷 2023-02-27 01 42 28" src="https://user-images.githubusercontent.com/106936018/221424009-487f3007-8645-48c9-80ad-a6d213e34ca8.png">

* struct임
* error 만나면 바로 Fail이 반환됨

```swift
guard let url = URL(string: "https://api.punkapi.com/v2/beers/random") else {
    return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
}
```



### ETC

* 추후 필요시 공부할 Publishers
    * empty
    * Record
    * Deferred



<br/>

## Subscribers

<img width="480" alt="스크린샷 2023-02-27 01 42 35" src="https://user-images.githubusercontent.com/106936018/221424015-6519008d-ada4-4b24-a138-2e48653f2cf5.png">

* Protocol임
* publisher에게 값을 받기 위해 선언해둔 프로토콜
* (Publisher의 Output == Subscriber의 Input) 해야함
* `Input` `Failure` `receive(subscription:)` `receive(input:)` `receive(completion:)` 구현 해야함
    * `Input`
        * Publisher에게 받는 값의 타입
    * `Failure`
        * Publisher에게 받는 Error타입
    * `receive(subscription:)`
        * Publisher가 만들어서 주는 subscription을 받는다
    * `receive(input:)`
        * Publisher가 주는 값을 받음
        * Demand를 반환(Demand: 값을 더 원하는지에 대한 여부 == subscription을 통해 subscriber가 publish에게 보낸 request 횟수)
    * `receive(completion:)`
        * Publisher가 주는 completion event를 받음

* Subscribers(== Subscriber 역할을 하는 타입들을 정의해둔 곳)
    * Sink
    * Assign
    * 기타 Subscribers 하위 속성
        * Demand
        * Completion

          



### Sink

* class임
* 횟수제한 없이 Subsctiption을 통해 값을 요청 가능
* sink cancel 시점 확인

```swift
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

//2번째 Value: Jack
//1번째 Value: Jack
//2번째 Value: Hue
//2번째 ✅ finished
```





### Assign

* class임
* key path로 표시된 `프로퍼티`에 수신된 값을 할당하는 subscriber

```swift
class MyObject {
    var strValue: String {
        didSet {
            print("changed: \(strValue)")
        }
    }
        
    init(strValue: String) {
        self.strValue = strValue
    }
        
    deinit {
        print("MyObject deinit")
    }
}
    
let myObject = MyObject(strValue: "Jack")
```

* Assign Subscriber를 직접 생성

```swift
let assign = Subscribers.Assign<MyObject, String>.init(object: myObject, keyPath: \.strValue)
    
["a", "b", "c", "d", "e"].publisher
    .subscribe(assign)
```

* `.assign(to: on:)` 매서드 이용

```swift
["a", "b", "c", "d", "e"].publisher
    .assign(to: \.strValue, on: myObject)
```

```swift
//changed: a
//changed: b
//changed: c
//changed: d
//changed: e
//e
//MyObject deinit
```



### Demand

* Subscriber가 Publisher에게 값 request한 횟수
* Subscriber가 Publisher에게 얼만큼의 횟수의 값을 받겠다는 걸 지정 해줄수 있음(Apple에서 Subscriber 커스텀 할수 있게 만들어놓은 느낌이다.)
* 3가지 지정 가능 `.unlimited` `.none`  `max(_ value: Int)`
    * `.unlimited`
        * 계속해서 값을 받겠다
    * `.none`
        * 요청을 하지 않겠다(==max(0))
    * `max(_ value: Int)`
        * 지정해준 만큼만 받겠다.

<img width="797" alt="스크린샷 2023-02-27 01 42 44" src="https://user-images.githubusercontent.com/106936018/221424026-9eac9cfc-ae18-4e65-bb41-a9ab19c85ea8.png">





```swift
class BaseSubscriber: Subscriber {
    typealias Input = String
    typealias Faliure = Never
    
		//  1️⃣
    func receive(subscription: Subscription) {
        print("구독시작")
        subscription.request(.max(1))
    }
    //  2️⃣    
    func receive(_ input: String) -> Subscribers.Demand {
        print("Input: \(input)")
      	// 1)
      	return .max(2)
	      // 2)
        return input == "a" ? .max(2) : .none

    }
        
    func receive(completion: Subscribers.Completion<Never>) {
        print("완료", completion)
    }
}


["a", "b", "c", "d", "e"]
    .publisher
    .print()
    .subscribe(BaseSubscriber())

```

* 1️⃣에서 최초로 받을 값 횟수 설정
* 2️⃣에서 반환한 값을 `추가로` 받겠다는 것
* 그래서 1) 일때 1 + 2 = 3개만 들어오는게 아니라, 추가로 값이 들어오면 2개 추가로 반환 하겠다는 것
* 2)일때  는 `.none` 으로 다음에 추가로 반환할 걸 막아서 3개만 들어옴

* 1경우 print()

```swift
receive subscription: (["a", "b", "c", "d", "e"])
구독시작
request max: (1)
receive value: (a)
Input: a
request max: (2) (synchronous)
receive value: (b)
Input: b
request max: (2) (synchronous)
receive value: (c)
Input: c
request max: (2) (synchronous)
receive value: (d)
Input: d
request max: (2) (synchronous)
receive value: (e)
Input: e
request max: (2) (synchronous)
receive finished
완료 finished
```

* 2경우 print()

```swift
receive subscription: (["a", "b", "c", "d", "e"])
구독시작
request max: (1)
receive value: (a)
Input: a
request max: (2) (synchronous)
receive value: (b)
Input: b
receive value: (c)
Input: c
```



### Completion

* 완료나 failure를 던져서 더이상 publisher 생명 끝

<img width="787" alt="스크린샷 2023-02-27 01 42 53" src="https://user-images.githubusercontent.com/106936018/221424035-d0d2f609-9bee-47b3-ad66-1c1ebbea042f.png">





<br/>

## Subscription

<img width="492" alt="스크린샷 2023-02-27 01 43 02" src="https://user-images.githubusercontent.com/106936018/221424046-41f59ab9-ca3a-468c-bdd5-cc34a81af317.png">





* protocol임
* Publisher와 Subscriber를 연결하는 프로토콜
* `request(_ demand: Subscribers.Demand)` 구현해야함(==구독후 publisher에서 subscription이 넘어올때 호출됌)
* 즉 Subscriber가 Publisher에게 값을 요청할 때 subscription을 사용
* `cancel()`매서드를 통해 취소 가능 + 해제 시점에 호추로딜 클로저 설정 가능(with. `.habdleEvents`)



<br/>

## Subject

* protocol임
* Publisher를 채택하고 있음.
* Subject는 stream에 `send(_ :)` 메서드를 호출해서 값을 주입할 수 있는 Publisher(Rx와 구현 되어 있는 방식은 다르지만 의미는 동일)
* 3개의 필수 `send` 매서드 존재 --> value, completion, subscription 하기 위해 존재
* `PassthroughSubject` 와 `CurrentValueSubject` 가 Subject 채택 받고 있음.

### CurrentValueSubject

<img width="471" alt="스크린샷 2023-02-27 01 43 10" src="https://user-images.githubusercontent.com/106936018/221424049-6279da28-5d7a-483f-a268-ef314d7c156f.png">

* Rx의 BehaviorSubject 
* 최신값을 구독자에게 broadcast(bind시점에 초기값 inject(==Apple에서는 emit을 inject라 하는 듯))
* 가장최근 값을 가지고 있음(버퍼) --> 즉 어딘가에 항상 최신값을 저장 중 일 것(궁금해서 찾아봤는데 딱걸림(아래사진))
* 최근 값 `.value`로 불러 올 수 있음

<img width="736" alt="스크린샷 2023-02-27 01 43 18" src="https://user-images.githubusercontent.com/106936018/221424055-354aa9e9-48d2-4058-a533-36a39e081cf9.png">

* 순서는 보장하지 않음

```swift
let currentValueSubject = CurrentValueSubject<String, Never>("Jack")
    
currentValueSubject.sink { print("1번째 \($0)") }
currentValueSubject.sink { print("2번째 \($0)") }
currentValueSubject.sink { print("3번째 \($0)") }
    
currentValueSubject.send("Hue")

//1번째 Jack
//2번째 Jack
//3번째 Jack
//2번째 HUE
//1번째 HUE
//3번째 HUE
```

* 구독취소 시점 확인 및 고민

```swift
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

//1번째 Value: Jack //1번째 초기값 inject하고 사망 
//2번째 Value: Jack
//2번째 Value: Hue
//2번째 ✅ finished --> 2번째 completion되서 Publisher생명 끝
```





### PassthroughSubject

<img width="472" alt="스크린샷 2023-02-27 01 45 42" src="https://user-images.githubusercontent.com/106936018/221424161-eef283e6-193e-47a8-ac46-b650af9d6e49.png">

* Rx의 PublishSubect 
* 초기값 없음(`passthrough` 즉 값이 스쳐 지나가기만 함) --> 따라서 `.value` 최신값에 접근 못함.
* 구독시점에 inject안함

```swift
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

//1번째 Value: Jack
//1번째 Value: Hue
//2번째 Value: Hue
```

