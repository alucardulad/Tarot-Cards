//
//  DailyDrawHistoryViewController.swift
//  tarot_cards
//
//  Created by 小萌 on 2026/2/3.
//

import UIKit
import SnapKit

class DailyDrawHistoryViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var history: [[String: Any]] = []
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置统一导航栏
        setupUnifiedNavigationBar(title: "签到历史")

        // 设置统一背景特效
        setupPageBackground(hasStarfield: true, hasAmbientLight: true)

        view.backgroundColor = .systemBackground
        setupUI()
        loadHistory()
    }
    
    private func setupUI() {
        // 空状态提示
        emptyLabel.text = "还没有签到记录\n快去抽取今日运势吧~ 💕"
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.systemFont(ofSize: 16)
        emptyLabel.textColor = .systemGray
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
        
        // 表格视图
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DailyDrawHistoryCell.self, forCellReuseIdentifier: "DailyDrawHistoryCell")
        tableView.separatorStyle = .none
        tableView.isHidden = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func loadHistory() {
        history = DailyDrawManager.shared.getDrawHistory()
        
        if history.isEmpty {
            emptyLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension DailyDrawHistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DailyDrawHistoryCell", for: indexPath) as! DailyDrawHistoryCell
        let record = history[indexPath.row]
        cell.configure(with: record)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DailyDrawHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let record = history[indexPath.row]
        if let cardsData = record["cards"] as? [[String: Any]],
           let timestamp = record["timestamp"] as? TimeInterval {
            
            let date = Date(timeIntervalSince1970: timestamp)
            let dateStr = date.toString(format: "yyyy年MM月dd日")
            
            let alert = UIAlertController(title: dateStr, 
                                        message: "点击查看详细记录", 
                                        preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "分享给闺蜜", style: .default) { _ in
                self.shareRecord(record: record)
            })
            
            alert.addAction(UIAlertAction(title: "关闭", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    private func shareRecord(record: [String: Any]) {
        // 这里可以调用之前的分享功能
        // 为了简化，先显示提示
        let alert = UIAlertController(title: "分享功能", 
                                    message: "正在开发中，敬请期待哦~ 💕", 
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - 历史记录单元格
class DailyDrawHistoryCell: UITableViewCell {
    
    private let dateLabel = UILabel()
    private let cardsStack = UIStackView()
    private let summaryLabel = UILabel()
    private let streakLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 背景
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
        backgroundView.layer.cornerRadius = 12
        contentView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        // 日期标签
        dateLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dateLabel.textColor = ThemeManager.shared.textColor
        backgroundView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        
        // 连续签到标签
        streakLabel.font = UIFont.italicSystemFont(ofSize: 14)
        streakLabel.textColor = ThemeManager.shared.secondaryColor
        backgroundView.addSubview(streakLabel)
        streakLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(16)
        }
        
        // 卡牌栈
        cardsStack.axis = .horizontal
        cardsStack.distribution = .fillEqually
        cardsStack.spacing = 8
        backgroundView.addSubview(cardsStack)
        cardsStack.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(16)
            make.height.equalTo(80)
        }
        
        // 总结标签
        summaryLabel.numberOfLines = 0
        summaryLabel.font = UIFont.systemFont(ofSize: 14)
        summaryLabel.textColor = ThemeManager.shared.textColor
        backgroundView.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(cardsStack.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func configure(with record: [String: Any]) {
        // 日期
        if let dateStr = record["date"] as? String {
            dateLabel.text = dateStr
        }
        
        // 连续签到（这里简化处理，实际可以根据记录计算）
        if let timestamp = record["timestamp"] as? TimeInterval {
            let today = Date().toString(format: "yyyy-MM-dd")
            let recordDate = Date(timeIntervalSince1970: timestamp).toString(format: "yyyy-MM-dd")
            
            if recordDate == today {
                streakLabel.text = "今日"
                streakLabel.textColor = .systemGreen
            } else {
                streakLabel.text = "✓"
                streakLabel.textColor = ThemeManager.shared.secondaryColor
            }
        }
        
        // 卡牌
        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let cardsData = record["cards"] as? [[String: Any]] {
            for cardData in cardsData {
                let cardView = UIView()
                cardView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
                cardView.layer.cornerRadius = 8
                cardView.layer.borderColor = UIColor.systemPurple.cgColor
                cardView.layer.borderWidth = 1
                
                let nameLabel = UILabel()
                nameLabel.font = UIFont.boldSystemFont(ofSize: 12)
                nameLabel.textColor = .systemPurple
                nameLabel.text = cardData["name"] as? String ?? "未知"
                nameLabel.textAlignment = .center
                cardView.addSubview(nameLabel)
                nameLabel.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                }
                
                cardsStack.addArrangedSubview(cardView)
            }
        }
        
        // 总结
        if let analysis = record["analysis"] as? String {
            summaryLabel.text = analysis
        } else {
            summaryLabel.text = "运势分析中..."
        }
    }
}