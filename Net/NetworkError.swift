import Foundation
import Alamofire

public enum NetworkError: Error {
    case underlying(Error)
    case decoding(Error)
    case server(statusCode: Int, data: Data?)
    case unknown

    static func from(afError: AFError, data: Data?) -> NetworkError {
        if let code = afError.responseCode {
            return .server(statusCode: code, data: data)
        }
        if let underlying = afError.underlyingError {
            return .underlying(underlying)
        }
        return .unknown
    }
}
