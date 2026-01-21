import Foundation

// 响应模型（命名为 ChatCompletionResult，避免与现有文件冲突）
public struct ChatCompletionResult: Decodable {
    public let id: String?
    public let object: String?
    public let created: Int?
    public let model: String?
    public let choices: [ChatChoiceResult]
    public let usage: ChatUsageResult?
}

public struct ChatChoiceResult: Decodable {
    public let index: Int?
    public let message: ChatMessageResult?
    public let finish_reason: String?
}

public struct ChatMessageResult: Decodable {
    public let role: String?
    public let content: String?
}

public struct ChatUsageResult: Decodable {
    public let prompt_tokens: Int?
    public let completion_tokens: Int?
    public let total_tokens: Int?
}
