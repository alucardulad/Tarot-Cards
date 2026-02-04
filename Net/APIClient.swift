import Foundation
import Alamofire

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var headers: HTTPHeaders? { get }
    /// 可选的原始 body 数据（用于 Encodable 请求体）
    var bodyData: Data? { get }
}

public extension APIEndpoint {
    var url: String { API.baseURL + path }
    var encoding: ParameterEncoding { JSONEncoding.default }
    var headers: HTTPHeaders? { nil }
    var parameters: Parameters? { nil }
    var bodyData: Data? { nil }
}

public enum API {
    public static var baseURL = "https://open.bigmodel.cn/api/paas/v4"
    /// 可选的全局鉴权 token，若为空则不会加 `Authorization` header
    public static var authToken: String? = "f0e6dcce84704cd79cb9b9d2d42ac259.gwuUUJWqdLqL26Jn"
    /// 默认 Content-Type，可按需修改
    public static var defaultContentType: String = "application/json"
}

/// 统一的接口枚举，按需扩展更多 case
public enum Endpoint: APIEndpoint {
    case tarotDraw(count: Int)
    case chatCompletions(model: String, messages: [ChatRequestMessage], stream: Bool)

    public var path: String {
        switch self {
        case .tarotDraw: return "/tarot/draw"
        case .chatCompletions: return "/chat/completions"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .tarotDraw: return .get
        case .chatCompletions: return .post
        }
    }

    public var parameters: Parameters? {
        switch self {
        case .tarotDraw(let count): return ["count": count]
        case .chatCompletions: return nil
        }
    }

    public var encoding: ParameterEncoding {
        switch self {
        case .tarotDraw: return URLEncoding.default
        case .chatCompletions: return JSONEncoding.default
        }
    }

    public var headers: HTTPHeaders? {
        var h = HTTPHeaders()
        h.add(name: "Content-Type", value: API.defaultContentType)
        
        switch self {
        case .chatCompletions:
            if let token = API.authToken {
                h.add(name: "Authorization", value: "Bearer \(token)")
            }
        default:
            break
        }
        return h
    }
    
    public var bodyData: Data? {
        switch self {
        case .chatCompletions(let model, let messages, let stream):
            struct Req: Encodable {
                let model: String
                let messages: [ChatRequestMessage]
                let stream: Bool
            }
            let req = Req(model: model, messages: messages, stream: stream)
            return try? JSONEncoder().encode(req)
        default:
            return nil
        }
    }
}
