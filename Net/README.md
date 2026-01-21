# Net 网络封装

本目录为基于 `Alamofire` 的网络封装示例。

使用示例：

```swift
import Foundation

// 假设有模型 TarotCard: Decodable
NetworkManager.shared.request(Endpoint.tarotDraw(count: 3)) { (result: Result<[TarotCard], NetworkError>) in
    switch result {
    case .success(let cards):
        print("drawn", cards)
    case .failure(let err):
        print("network error", err)
    }
}
```

示例：调用 DeepSeek 的 chat/completions 接口

```swift
let messages: [ChatRequestMessage] = [
    ChatRequestMessage(role: "system", content: "You are a helpful assistant."),
    ChatRequestMessage(role: "user", content: "Hello! 给我一句中文问候"),
]
API.baseURL = "https://api.deepseek.com"
API.authToken = "sk-0226815a5f0e4765994bfe81a1d39696"

NetworkManager.shared.request(Endpoint.chatCompletions(model: "deepseek-chat", messages: messages, stream: false)) { (result: Result<ChatCompletionResult, NetworkError>) in
    switch result {
    case .success(let resp):
        if let first = resp.choices.first?.message?.content {
            print("reply:", first)
        } else {
            print("no reply")
        }
    case .failure(let err):
        print("chat error", err)
    }
}
```

或使用 `ChatService` 的便捷方法获取首条文本回复：

```swift
ChatService.sendText(messages: messages) { result in
    switch result {
    case .success(let text):
        print("first reply:", text)
    case .failure(let err):
        print("chat error", err)
    }
}
```

要点：
- `API.baseURL` 可根据需要修改。
- 若需上传、下载或自定义序列化，可在 `NetworkManager` 中扩展方法。
