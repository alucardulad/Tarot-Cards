import Foundation
import Alamofire

public final class NetworkManager {
    public static let shared = NetworkManager()
    private init() {}

    @discardableResult
    public func request<T: Decodable>(_ endpoint: APIEndpoint, completion: @escaping (Result<T, NetworkError>) -> Void) -> DataRequest {
        // 如果 endpoint 提供了 bodyData，优先使用 URLRequest 发送原始 body
        if let body = endpoint.bodyData {
            guard let url = URL(string: endpoint.url) else {
                completion(.failure(.unknown))
                return AF.request(endpoint.url)
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = endpoint.method.rawValue

            if let headers = endpoint.headers {
                for header in headers {
                    urlRequest.setValue(header.value, forHTTPHeaderField: header.name)
                }
            }
            // 确保 Content-Type 存在
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue(API.defaultContentType, forHTTPHeaderField: "Content-Type")
            }

            urlRequest.httpBody = body

            let request = AF.request(urlRequest)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        completion(.success(value))
                    case .failure(let afError):
                        completion(.failure(NetworkError.from(afError: afError, data: response.data)))
                    }
                }

            return request
        }

        // 否则使用原来的 parameters + encoding 路径
        let request = AF.request(endpoint.url,
                                 method: endpoint.method,
                                 parameters: endpoint.parameters,
                                 encoding: endpoint.encoding,
                                 headers: endpoint.headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let afError):
                    completion(.failure(NetworkError.from(afError: afError, data: response.data)))
                }
            }

        return request
    }
}
