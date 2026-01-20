//
//  DrawViewController.swift
//  tarot_cards
//
//  Created by copilot on 2026/1/20.
//

import UIKit
import SnapKit

class DrawViewController: UIViewController {
    private let logoLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let suggestionsStack = UIStackView()
    private let bottomInputBar = UIView()
    private let messageField = UITextField()
    private let plusButton = UIButton(type: .system)

    private var suggestions: [String] = []
    private let defaultSuggestions: [String] = [
        "",
        "",
        ""
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        suggestions = loadRecentQuestions()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh suggestions from history each time the view appears
        let newSuggestions = loadRecentQuestions()
        if newSuggestions != suggestions {
            suggestions = newSuggestions
            // clear existing arranged subviews
            for v in suggestionsStack.arrangedSubviews {
                suggestionsStack.removeArrangedSubview(v)
                v.removeFromSuperview()
            }
            // add new rows
            for suggestion in suggestions {
                let row = suggestionRow(text: suggestion)
                suggestionsStack.addArrangedSubview(row)
            }
        }
    }

    private func setupUI() {
        // Logo
        logoLabel.text = "TAROT CARD"
        logoLabel.font = UIFont.systemFont(ofSize: 44, weight: .heavy)
        logoLabel.textColor = UIColor.systemPink
        logoLabel.textAlignment = .center
        view.addSubview(logoLabel)
        logoLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            make.centerX.equalToSuperview()
        }

        // Subtitle
        subtitleLabel.text = "今天我有什么能帮助你的?"
        subtitleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        subtitleLabel.textAlignment = .center
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // Suggestions stack
        suggestionsStack.axis = .vertical
        suggestionsStack.spacing = 12
        view.addSubview(suggestionsStack)
        suggestionsStack.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        for suggestion in suggestions {
            let row = suggestionRow(text: suggestion)
            suggestionsStack.addArrangedSubview(row)
        }

        // Bottom input bar
        bottomInputBar.backgroundColor = UIColor.systemGray6
        bottomInputBar.layer.cornerRadius = 22
        view.addSubview(bottomInputBar)
        bottomInputBar.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-72)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(48)
        }

        messageField.placeholder = "Message"
        messageField.borderStyle = .none
        messageField.backgroundColor = .clear
        bottomInputBar.addSubview(messageField)
        messageField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-44)
            make.height.equalTo(36)
        }
        

        // chat icon on right inside bar
        let chatIcon = UIImageView(image: UIImage(systemName: "text.bubble") )
        chatIcon.tintColor = .systemBlue
        bottomInputBar.addSubview(chatIcon)
        chatIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        chatIcon.isHidden = true

        // Floating plus button
        plusButton.backgroundColor = .systemBlue
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.layer.cornerRadius = 24
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        view.addSubview(plusButton)
        plusButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(bottomInputBar.snp.centerY)
            make.width.height.equalTo(48)
        }
    }

    private func suggestionRow(text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray6
        container.layer.cornerRadius = 12

        let icon = UIImageView(image: UIImage(systemName: "info.circle"))
        icon.tintColor = .systemBlue
        container.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        let label = UILabel()
        label.text = text
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16)
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalTo(icon.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-44)
        }

        let arrow = UIImageView(image: UIImage(systemName: "chevron.up.circle.fill"))
        arrow.tintColor = .systemBlue
        container.addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(suggestionTapped(_:)))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        container.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        // store text in accessibilityLabel for retrieval in handler
        container.accessibilityLabel = text

        return container
    }

    @objc private func suggestionTapped(_ g: UITapGestureRecognizer) {
        guard let view = g.view, let text = view.accessibilityLabel else { return }
        goToDraw(with: text)
    }

    @objc private func plusTapped() {
        let text = messageField.text ?? ""
        goToDraw(with: text)
    }

    private func goToDraw(with question: String) {
        let resultVC = ResultViewController()
        resultVC.question = question
        resultVC.shouldAutoDraw = true
        navigationController?.pushViewController(resultVC, animated: true)
    }

    // Load up to 5 recent questions from drawHistory in UserDefaults
    private func loadRecentQuestions() -> [String] {
        if let history = UserDefaults.standard.array(forKey: "drawHistory") as? [[String: Any]], history.count > 0 {
            var questions: [String] = []
            for entry in history {
                if let q = entry["question"] as? String, !q.isEmpty {
                    questions.append(q)
                    if questions.count >= 5 { break }
                }
            }
            if !questions.isEmpty { return questions }
        }
        return defaultSuggestions
    }
}
