//
//  TarotCard.swift
//  tarot_cards
//
//  Created by alucardulad on 2026/1/20.
//

import UIKit

struct TarotCard: Codable {
    let id: Int
    let name: String
    let image: String
    let upright: String
    let reversed: String
    
    /// 卡牌方向: true 表示正位，false 表示逆位
    var isUpright: Bool = true
    
    /// 获取当前方向的含义
    var currentMeaning: String {
        return isUpright ? upright : reversed
    }
    
    /// 获取当前方向的文字
    var directionText: String {
        return isUpright ? "正位" : "逆位"
    }
}

class TarotCardManager {
    static let shared = TarotCardManager()
    
    private var allCards: [TarotCard] = []
    
    private init() {
        loadCardsFromPlist()
    }
    
    /// 从plist加载所有塔罗牌
    private func loadCardsFromPlist() {
        var plistArray: [[String: Any]]? = nil

        // 1. 尝试直接从主 bundle 根目录加载
        if let url = Bundle.main.url(forResource: "tarot_cards", withExtension: "plist") {
            if let data = try? Data(contentsOf: url),
               let arr = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] {
                plistArray = arr
            }
        }

        // 2. 尝试从子目录 "other" 加载（如果在资源分组中保留了目录结构）
        if plistArray == nil {
            if let path = Bundle.main.path(forResource: "tarot_cards", ofType: "plist", inDirectory: "other"),
               let data = FileManager.default.contents(atPath: path),
               let arr = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]] {
                plistArray = arr
            }
        }

        guard let finalArray = plistArray else {
            print("无法加载 plist 文件: 请确认 `tarot_cards.plist` 已加入到 Target 的 Copy Bundle Resources 中。")
            return
        }

        allCards = finalArray.compactMap { dict in
            guard let id = dict["id"] as? Int,
                  let name = dict["name"] as? String,
                  let image = dict["image"] as? String,
                  let upright = dict["upright"] as? String,
                  let reversed = dict["reversed"] as? String else {
                return nil
            }
            return TarotCard(id: id, name: name, image: image, upright: upright, reversed: reversed)
        }

        print("已加载 \(allCards.count) 张塔罗牌")
    }
    
    /// 随机抽取3张不重复的塔罗牌，每张随机分配正位或逆位
    func drawThreeRandomCards() -> [TarotCard] {
        var selectedCards = allCards.shuffled().prefix(3).map { card -> TarotCard in
            var card = card
            card.isUpright = Bool.random()
            return card
        }
        return Array(selectedCards)
    }
    
    /// 随机抽取1张不重复的塔罗牌，每张随机分配正位或逆位
    func drawOneRandomCards() -> [TarotCard] {
        var selectedCards = allCards.shuffled().prefix(1).map { card -> TarotCard in
            var card = card
            card.isUpright = Bool.random()
            return card
        }
        return Array(selectedCards)
    }

    /// 获取所有塔罗牌（用于鉴赏模式）
    func getAllCards() -> [TarotCard] {
        return allCards
    }
}
