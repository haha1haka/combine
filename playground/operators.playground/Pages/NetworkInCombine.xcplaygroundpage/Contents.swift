//: [Previous](@previous)

import Foundation
import Combine

struct Bear: Codable {
    let id: Int
    let name: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageURL = "image_url"
    }
}

var anyCancellable = Set<AnyCancellable>()

class NetworkService {
    
    static var shared = NetworkService()
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getAPI() -> AnyPublisher<[Bear], URLError> {
        
        guard let url = URL(string: "https://api.punkapi.com/v2/beers/random") else {
            print("asdf''")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.unknown)
                }
                
                switch httpResponse.statusCode {
                case 200..<300:
                    return data
                case 400..<500:
                    throw URLError(.clientCertificateRejected)
                case 500..<599:
                    throw URLError(.badServerResponse)
                default:
                    throw URLError(.unknown)
                }
            }
            .decode(type: [Bear].self, decoder: JSONDecoder())
            .map { $0 }
            .mapError { $0 as! URLError }
            .eraseToAnyPublisher()
    }
    
}

var bearList = CurrentValueSubject<[Bear], Never>([])

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



bearList
    .sink {
        print($0)
    }
    .store(in: &anyCancellable)


fetchBearList()



