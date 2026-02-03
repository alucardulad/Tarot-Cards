//
//  ShareManager.swift
//  tarot_cards
//
//  Created by 小萌 on 2026/2/3.
//

import UIKit
import SnapKit

class ShareManager {
    
    static let shared = ShareManager()
    
    private init() {}
    
    /// 生成塔罗牌分享图片
    func generateShareImage(question: String, cards: [TarotCard], analysis: String) -> UIImage? {
        // 创建画布尺寸
        let width: CGFloat = 750
        let height: CGFloat = 1334
        
        // 创建图形上下文
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 2.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 绘制背景
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                 colors: [UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor] as CFArray,
                                 locations: [0.0, 1.0])!
        context.drawLinearGradient(gradient,
                                 start: CGPoint(x: 0, y: 0),
                                 end: CGPoint(x: 0, y: height),
                                 options: [])
        
        // 添加装饰性元素
        context.setFillColor(UIColor.white.withAlphaComponent(0.1).cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: height - 200, width: 400, height: 400))
        
        // 标题
        let titleFont = UIFont.boldSystemFont(ofSize: 36)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.white,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
        
        let titleText = "今日塔罗运势"
        let titleSize = titleText.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: (width - titleSize.width) / 2, y: 80, width: titleSize.width, height: titleSize.height)
        titleText.draw(in: titleRect, withAttributes: titleAttributes)
        
        // 问题
        let questionFont = UIFont.systemFont(ofSize: 20)
        let questionAttributes: [NSAttributedString.Key: Any] = [
            .font: questionFont,
            .foregroundColor: UIColor.white,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                style.lineSpacing = 6
                return style
            }()
        ]
        
        let questionText = "我的问题：\(question)"
        let questionSize = questionText.size(withAttributes: questionAttributes)
        let questionRect = CGRect(x: (width - questionSize.width) / 2, y: 160, width: questionSize.width, height: questionSize.height * 1.5)
        questionText.draw(in: questionRect, withAttributes: questionAttributes)
        
        // 卡牌显示区域
        let cardSize: CGFloat = 180
        let cardSpacing: CGFloat = 20
        let totalCardWidth = cardSize * 3 + cardSpacing * 2
        let startX = (width - totalCardWidth) / 2
        let cardY = 260
        
        // 卡牌名称和含义
        for (index, card) in cards.enumerated() {
            let cardX = startX + CGFloat(index) * (cardSize + cardSpacing)
            
            // 卡牌背景框
            context.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(2)
            let cardRect = CGRect(x: cardX, y: cardY, width: cardSize, height: cardSize)
            context.addRect(cardRect)
            context.drawPath(using: .fillStroke)
            
            // 卡牌名称
            let cardNameFont = UIFont.boldSystemFont(ofSize: 18)
            let cardNameAttributes: [NSAttributedString.Key: Any] = [
                .font: cardNameFont,
                .foregroundColor: UIColor.white
            ]
            
            let cardNameText = card.name
            let cardNameSize = cardNameText.size(withAttributes: cardNameAttributes)
            let cardNameRect = CGRect(x: cardX + (cardSize - cardNameSize.width) / 2, 
                                     y: cardY + 20, 
                                     width: cardNameSize.width, 
                                     height: cardNameSize.height)
            cardNameText.draw(in: cardNameRect, withAttributes: cardNameAttributes)
            
            // 方位
            let directionFont = UIFont.systemFont(ofSize: 14)
            let directionAttributes: [NSAttributedString.Key: Any] = [
                .font: directionFont,
                .foregroundColor: UIColor.white
            ]
            
            let directionText = card.directionText
            let directionSize = directionText.size(withAttributes: directionAttributes)
            let directionRect = CGRect(x: cardX + (cardSize - directionSize.width) / 2, 
                                     y: cardY + 50, 
                                     width: directionSize.width, 
                                     height: directionSize.height)
            directionText.draw(in: directionRect, withAttributes: directionAttributes)
            
            // 含义（简化版）
            let meaningFont = UIFont.systemFont(ofSize: 12)
            let meaningAttributes: [NSAttributedString.Key: Any] = [
                .font: meaningFont,
                .foregroundColor: UIColor.white,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineSpacing = 4
                    style.alignment = .center
                    return style
                }()
            ]
            
            // 截取含义的前一部分
            let fullMeaning = card.currentMeaning
            let words = fullMeaning.components(separatedBy: "。")
            let shortMeaning = words.first ?? fullMeaning
            
            let meaningSize = shortMeaning.size(withAttributes: meaningAttributes)
            let meaningRect = CGRect(x: cardX + 10, 
                                     y: cardY + 80, 
                                     width: cardSize - 20, 
                                     height: 80)
            shortMeaning.draw(in: meaningRect, withAttributes: meaningAttributes)
        }
        
        // 解析文本（简化版）
        let analysisFont = UIFont.systemFont(ofSize: 14)
        let analysisAttributes: [NSAttributedString.Key: Any] = [
            .font: analysisFont,
            .foregroundColor: UIColor.white,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 4
                style.alignment = .center
                return style
            }()
        ]
        
        // 提取解析文本的关键部分
        let analysisLines = analysis.components(separatedBy: "\n")
        var shortAnalysis = ""
        for line in analysisLines {
            if line.contains("过去") || line.contains("现在") || line.contains("发展") {
                shortAnalysis += line + "\n"
            }
            if shortAnalysis.count > 200 { break }
        }
        
        if shortAnalysis.isEmpty {
            shortAnalysis = "塔罗牌解读：运势正在展开，相信内心的指引。"
        }
        
        let analysisSize = shortAnalysis.size(withAttributes: analysisAttributes)
        let analysisRect = CGRect(x: 50, y: cardY + cardSize + 40, width: width - 100, height: analysisSize.height * 3)
        shortAnalysis.draw(in: analysisRect, withAttributes: analysisAttributes)
        
        // 底部分享语
        let shareFont = UIFont.italicSystemFont(ofSize: 16)
        let shareAttributes: [NSAttributedString.Key: Any] = [
            .font: shareFont,
            .foregroundColor: UIColor.white,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
        ]
        
        let shareText = "🔮 占卜源于神秘，解读归于智慧 🔮"
        let shareSize = shareText.size(withAttributes: shareAttributes)
        let shareRect = CGRect(x: (width - shareSize.width) / 2, y: height - 100, width: shareSize.width, height: shareSize.height)
        shareText.draw(in: shareRect, withAttributes: shareAttributes)
        
        // 生成图片
        let shareImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return shareImage
    }
    
    /// 分享到系统分享菜单
    func presentShareSheet(from viewController: UIViewController, 
                          question: String, 
                          cards: [TarotCard], 
                          analysis: String) {
        
        // 生成分享图片
        guard let shareImage = generateShareImage(question: question, cards: cards, analysis: analysis) else {
            showAlert(from: viewController, title: "分享失败", message: "无法生成分享图片")
            return
        }
        
        // 创建分享项目
        let activityViewController = UIActivityViewController(
            activityItems: [shareImage],
            applicationActivities: nil
        )
        
        // 排除不需要的分享选项
        activityViewController.excludedActivityTypes = [
            .postToFacebook,
            .postToTwitter,
            .postToWeibo,
            .mail,
            .print,
            .copyToPasteboard,
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo
        ]
        
        // 在iPad上显示时的配置
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    /// 显示提示消息
    private func showAlert(from viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        viewController.present(alert, animated: true)
    }
}