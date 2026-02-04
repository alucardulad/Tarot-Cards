import Foundation

/// 简单的 Chat API 封装，调用 `Endpoint.chatCompletions` 并返回解析后的结果或首条文本回复。
public final class ChatService {
    private init() {}

    @discardableResult
    public static func send(model: String = "glm-4.7-flash", messages: [ChatRequestMessage], stream: Bool = false, completion: @escaping (Result<ChatCompletionResult, NetworkError>) -> Void) -> Void {
        let endpoint = Endpoint.chatCompletions(model: model, messages: messages, stream: stream)
        NetworkManager.shared.request(endpoint, completion: completion)
    }

    /// 便捷方法：只返回第一条回复文本（如果存在）
    public static func sendText(model: String = "glm-4.7-flash", messages: [ChatRequestMessage], stream: Bool = false, completion: @escaping (Result<String, NetworkError>) -> Void) {
        send(model: model, messages: messages, stream: stream) { (result: Result<ChatCompletionResult, NetworkError>) in
            switch result {
            case .success(let resp):
                if let text = resp.choices.first?.message?.content {
                    completion(.success(text))
                } else {
                    completion(.failure(.unknown))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
}
