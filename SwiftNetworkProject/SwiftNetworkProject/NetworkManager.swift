//
//  NetworkManager.swift
//  SwiftNetworkProject
//
//  Created by 이유리 on 2023/07/20.
//

import Foundation
import Alamofire
import Moya

enum NetworkError: Error {
    case networkingError
    case dataError
    case parseError
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    typealias NetworkCompletionHandler = (Result<GetResponse, NetworkError>) -> Void
    
    // 1. URLSession
    func requestGetMethod(with urlString: String, completion: @escaping NetworkCompletionHandler) {

        // 1. 네트워크를 실행할 url
//        guard let url = URL(string: urlString) else { return }
//
//        let session = URLSession(configuration: .default)
//
//        let task = session.dataTask(with: url) { data, response, error in
//            if error != nil {
//                print(error!)
//                completion(.failure(.networkingError))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(.dataError))
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
//                completion(.failure(.networkingError))
//                return
//            }
//
//            // 메서드 실행해서, 결과를 받음
//            if let data = self.parseJSON(data) {
//                print("Parse 실행")
//                completion(.success(data))
//            } else {
//                print("Parse 실패")
//                completion(.failure(.parseError))
//            }
//        }
//
//        // 통신 실행
//        task.resume()
//
        //2. Alamofire
        AF.request(urlString)
            .validate()  //44번째 줄 라인처럼 200..<299 내에 statusCode가 있는지 확인해줌. 실패시 아래에서 error 전달
            .responseDecodable(of: GetResponse.self) { response in
                switch response.result {  // return 타입이 Result<Success, Failure>
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    print(error)
                    completion(.failure(.parseError))
                }
            }
        
    }
    
    private func parseJSON(_ data: Data) -> GetResponse? {
        let decoded = try? JSONDecoder().decode(GetResponse.self, from: data)
        return decoded
    }
    
    func postRequest(with urlString: String, postBody: UploadData, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        // 1. URLSession
        guard let url = URL(string: urlString) else {
            return
        }

        // 1-1)모델을 JSON data 형태로 변환 (encode)
        guard let jsonData = try? JSONEncoder().encode(postBody) else {
            return
        }

        // URL요청 생성
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // 헤더값 설정
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData


        // 요청을 가지고 세션 작업시작
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 에러가 없어야 넘어감
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                return
            }
            // 옵셔널 바인딩
            guard data != nil else {
                print("Error: Did not receive data")
                return
            }
            // HTTP 200번대 정상코드인 경우만 다음 코드로 넘어감
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }

            // 원하는 모델이 있다면, JSONDecoder로 decode코드로 구현 ⭐️
            completion(.success(true))

        }.resume()   // 시작
        
        //2. Alamofire
        AF.request(urlString, method: .post, parameters: postBody)
            .validate()  //44번째 줄 라인처럼 200..<299 내에 statusCode가 있는지 확인해줌. 실패시 아래에서 error 전달
            .response { response in
                switch response.result {
                case .success(_):
                    completion(.success(true))
                case .failure(let error):
                    print(error)
                }
            }
    }
}
