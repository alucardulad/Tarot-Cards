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
        context.fillEllipse(in: CGRect(x: 0, y: height - CGFloat(200), width: CGFloat(400), height: CGFloat(400)))
        
        // 标题（放大）
        let titleFont = UIFont.boldSystemFont(ofSize: 44)
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
        let titleRect = CGRect(x: (width - titleSize.width) / 2, y: CGFloat(80), width: titleSize.width, height: titleSize.height)
        titleText.draw(in: titleRect, withAttributes: titleAttributes)
        
        // 问题（放大）
        let questionFont = UIFont.systemFont(ofSize: 24)
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
        let questionRect = CGRect(x: (width - questionSize.width) / 2, y: CGFloat(160), width: questionSize.width, height: questionSize.height * 1.5)
        questionText.draw(in: questionRect, withAttributes: questionAttributes)
        
        // 卡牌显示区域：按 ResultViewController 的布局比例（在设备点数上：卡高 320pt，image 为高度的 70%），
        // 在分享图上使用 @2x 分辨率（宽度 750），所以将点数翻倍。
        let uiMargin: CGFloat = 12    // Result VC 的左右边距（pt），减小以使卡边框更靠近画布
        let uiSpacing: CGFloat = 12   // Result VC 的卡片间距（pt）
        let scaleFactor: CGFloat = 2.0 // 分享图相对于 pt 的像素缩放

        let margin = uiMargin * scaleFactor    // 32
        let spacing = uiSpacing * scaleFactor  // 24
        let cardHeight: CGFloat = 320 * scaleFactor // 640 (与 ResultViewController 中高度一致的翻倍值)
        let availableWidth = width - margin * 2
        let cardWidth = (availableWidth - spacing * 2) / 3
        let totalCardWidth = cardWidth * 3 + spacing * 2
        let startX = (width - totalCardWidth) / 2
        let cardY: CGFloat = 280

        // 对齐工具：把矩形对齐到分享图的像素网格，减少抗锯齿导致的边框粗细差异
        let alignRectToScale: (CGRect, CGFloat) -> CGRect = { rect, scale in
            let sx = round(rect.origin.x * scale) / scale
            let sy = round(rect.origin.y * scale) / scale
            let sw = round(rect.size.width * scale) / scale
            let sh = round(rect.size.height * scale) / scale
            return CGRect(x: sx, y: sy, width: sw, height: sh)
        }

        // 卡牌图片与含义（使用 cardWidth x cardHeight 的矩形）
        for (index, card) in cards.enumerated() {
            let cardX = startX + CGFloat(index) * (cardWidth + spacing)

            // 卡牌背景框（使用 UIBezierPath 绘制并对齐到像素）
            let strokeWidth: CGFloat = 2.0
            var cardRect = CGRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight)
            cardRect = alignRectToScale(cardRect, scaleFactor)
            let cornerRadius: CGFloat = 8.0
            let path = UIBezierPath(roundedRect: cardRect, cornerRadius: cornerRadius)
            path.lineWidth = strokeWidth
            UIColor.white.withAlphaComponent(0.18).setFill()
            UIColor.white.withAlphaComponent(0.25).setStroke()
            path.fill()
            path.stroke()

            // 绘制卡牌图片（替代名称），图片放在卡牌矩形的上方区域（与 CardDisplayView 中 imageView 占比一致，约 70%）
            if let img = UIImage(named: card.image) {
                let imageInset: CGFloat = 12
                let imageAreaHeight = cardHeight * 0.7
                let imageRect = CGRect(x: cardX + imageInset,
                                       y: cardY + imageInset,
                                       width: cardWidth - imageInset * 2,
                                       height: imageAreaHeight - imageInset)
                img.draw(in: imageRect)
            }

            // 方位（微增字体）
            let directionFont = UIFont.systemFont(ofSize: 18)
            let directionAttributes: [NSAttributedString.Key: Any] = [
                .font: directionFont,
                .foregroundColor: UIColor.white
            ]
            let directionText = card.directionText
            let directionSize = directionText.size(withAttributes: directionAttributes)
            let directionRect = CGRect(x: cardX + (cardWidth - directionSize.width) / 2,
                                      y: cardY + cardHeight + 8,
                                      width: directionSize.width,
                                      height: directionSize.height)
            directionText.draw(in: directionRect, withAttributes: directionAttributes)

            // 含义（显示在卡牌下方，放大字号并居中）
            let meaningFont = UIFont.systemFont(ofSize: 16)
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

            let fullMeaning = card.currentMeaning
            let words = fullMeaning.components(separatedBy: "。")
            let shortMeaning = (words.first?.isEmpty ?? true) ? fullMeaning : words.first ?? fullMeaning

            let meaningRect = CGRect(x: cardX + 8,
                                     y: cardY + cardHeight + 8 + directionSize.height + 8,
                                     width: cardWidth - 16,
                                     height: CGFloat(72))
            shortMeaning.draw(in: meaningRect, withAttributes: meaningAttributes)
        }
        
        // 解析文本（简化版，放大）
        let analysisFont = UIFont.systemFont(ofSize: 18)
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
            if line.contains("总结") {
                shortAnalysis = analysisLines[10] + "\n"
            }
        }
        
        if shortAnalysis.isEmpty {
            shortAnalysis = "塔罗牌解读：运势正在展开，相信内心的指引。"
        }
        
        let analysisSize = shortAnalysis.size(withAttributes: analysisAttributes)
        let analysisRect = CGRect(x: CGFloat(50), y: cardY + cardHeight + CGFloat(90), width: width - CGFloat(100), height: analysisSize.height * 4)
        shortAnalysis.draw(in: analysisRect, withAttributes: analysisAttributes)
        
        // 底部分享语
        let shareFont = UIFont.italicSystemFont(ofSize: 18)
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
        let shareRect = CGRect(x: (width - shareSize.width) / 2, y: height - CGFloat(90), width: shareSize.width, height: shareSize.height)
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
