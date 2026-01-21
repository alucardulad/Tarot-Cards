import Foundation

/// 请求侧消息类型（用于构建请求 body）
public struct ChatRequestMessage: Codable {
    public let role: String
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}
