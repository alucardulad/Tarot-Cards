import Foundation

// Request-side helper (optional). We use [[String: Any]] for messages in Endpoint,
// but define response models here for decoding.

public struct ChatCompletionResponse: Decodable {
    public let id: String?
    public let object: String?
    public let created: Int?
    public let model: String?
    public let choices: [ChatChoice]
    public let usage: ChatUsage?
}

public struct ChatChoice: Decodable {
    public let index: Int?
    public let message: ChatMessageResponse?
    public let finish_reason: String?
}

public struct ChatMessageResponse: Decodable {
    public let role: String?
    public let content: String?
}

public struct ChatUsage: Decodable {
    public let prompt_tokens: Int?
    public let completion_tokens: Int?
    public let total_tokens: Int?
}
