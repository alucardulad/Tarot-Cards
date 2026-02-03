import Foundation

struct HistoryEntry: Equatable {
    var id: String?
    var date: String
    var question: String
    var analysis: String?
    var timestamp: TimeInterval?
    var cards: [[String: Any]]?

    init(id: String? = nil, date: String = "", question: String = "", analysis: String? = nil, timestamp: TimeInterval? = nil, cards: [[String: Any]]? = nil) {
        self.id = id
        self.date = date
        self.question = question
        self.analysis = analysis
        self.timestamp = timestamp
        self.cards = cards
    }

    init?(dict: [String: Any]) {
        // HistoryManager.saveEntry always stores at least question and id/timestamp
        guard let question = dict["question"] as? String else { return nil }
        self.question = question
        self.id = dict["id"] as? String
        self.timestamp = dict["timestamp"] as? TimeInterval
        if let ts = self.timestamp {
            let d = Date(timeIntervalSince1970: ts)
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "zh_CN")
            fmt.dateFormat = "M月d日"
            self.date = fmt.string(from: d)
        } else {
            self.date = dict["date"] as? String ?? ""
        }
        self.analysis = dict["analysis"] as? String
        self.cards = dict["cards"] as? [[String: Any]]
    }

    func toDictionary() -> [String: Any] {
        var d: [String: Any] = ["question": question]
        if let id = id { d["id"] = id }
        if let ts = timestamp { d["timestamp"] = ts }
        if let a = analysis { d["analysis"] = a }
        if let c = cards { d["cards"] = c }
        return d
    }
}

// Custom Equatable: compare identity-relevant fields. We avoid deep-comparing `cards` ([[String:Any]]) because
// dictionaries with `Any` are not Equatable; comparing id/timestamp/question/analysis is sufficient for change detection
extension HistoryEntry {
    static func == (lhs: HistoryEntry, rhs: HistoryEntry) -> Bool {
        return lhs.id == rhs.id
            && lhs.timestamp == rhs.timestamp
            && lhs.question == rhs.question
            && lhs.analysis == rhs.analysis
            && lhs.date == rhs.date
    }
}
