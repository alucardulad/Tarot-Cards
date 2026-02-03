import UIKit
import SnapKit

class HistoryCell: UITableViewCell {
    static let reuseIdentifier = "HistoryCell"

    private let container = UIView()
    private let dateLabel = UILabel()
    private let questionLabel = UILabel()
    private let imagesStack = UIStackView()
    private var cardImageViews: [UIImageView] = []
    private let summaryLabel = UILabel()
    private let timeLabel = UILabel()
    // Use translucent container background; avoid per-cell live blur which iOS may disable during scrolling
    private let arrowButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(container)
        container.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        container.layer.masksToBounds = false
        // subtle outer shadow/glow to separate from busy background
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.28
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }

        // Keep container translucent; avoid per-cell live blur to prevent disappearing during scroll
        container.backgroundColor = UIColor(white: 0.03, alpha: 0.25)
        
        dateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        dateLabel.textColor = UIColor(white: 1.0, alpha: 0.9)
        container.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
        }

        questionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        questionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        questionLabel.numberOfLines = 0
        questionLabel.textColor = UIColor(white: 1.0, alpha: 0.95)
        container.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-56)
        }

        imagesStack.axis = .horizontal
        imagesStack.spacing = 8
        container.addSubview(imagesStack)
        imagesStack.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(48)
        }
        for _ in 0..<3 {
            let iv = UIImageView()
            iv.backgroundColor = UIColor.systemGray5
            iv.contentMode = .scaleAspectFit
            iv.layer.cornerRadius = 4
            iv.clipsToBounds = true
            iv.snp.makeConstraints { make in
                make.width.equalTo(48)
                make.height.equalTo(48)
            }
            imagesStack.addArrangedSubview(iv)
            cardImageViews.append(iv)
        }

        summaryLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        summaryLabel.textColor = UIColor(white: 0.93, alpha: 0.9)
        container.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints { make in
            make.top.equalTo(imagesStack.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }

        timeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        timeLabel.textColor = UIColor(white: 0.85, alpha: 0.9)
        timeLabel.textAlignment = .right
        
        // accessory arrow as button to provide ripple feedback
        arrowButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        arrowButton.tintColor = UIColor(white: 1.0, alpha: 0.85)
        arrowButton.backgroundColor = .clear
        arrowButton.addTarget(self, action: #selector(arrowTapped(_:)), for: .touchUpInside)
        container.addSubview(arrowButton)
        arrowButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        container.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-36)
            make.bottom.equalToSuperview().offset(-12)
            make.width.lessThanOrEqualTo(100)
        }
    }

    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        questionLabel.text = nil
        dateLabel.text = nil
        summaryLabel.text = nil
        timeLabel.text = nil
        for iv in cardImageViews { iv.image = nil; iv.backgroundColor = UIColor.systemGray5 }
        container.layer.removeAllAnimations()
        contentView.layer.removeAllAnimations()
        alpha = 1
        transform = .identity
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // update shadow path for performance
        container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds, cornerRadius: container.layer.cornerRadius).cgPath
    }

    func configure(with entry: HistoryEntry) {
        dateLabel.text = entry.date
        questionLabel.text = entry.question
        summaryLabel.text = entry.analysis
        if let ts = entry.timestamp {
            let date = Date(timeIntervalSince1970: ts)
            let diff = Int(Date().timeIntervalSince(date))
            let days = diff / 86400
            if days > 0 {
                timeLabel.text = "\(days)天前更新"
            } else {
                let hours = diff / 3600
                if hours > 0 { timeLabel.text = "\(hours)小时前更新" } else { timeLabel.text = "刚刚更新" }
            }
        } else {
            timeLabel.text = ""
        }

        // Cards saved by ResultViewController are dictionaries with keys: id, name, image, isUpright, meaning
        if let cards = entry.cards {
            for (i, cardDict) in cards.enumerated() where i < cardImageViews.count {
                let iv = cardImageViews[i]
                if let imageName = cardDict["image"] as? String {
                    if let img = UIImage(named: imageName) {
                        iv.image = img
                        iv.backgroundColor = .clear
                    } else {
                        iv.image = UIImage(named: "card_back")
                        iv.backgroundColor = UIColor.systemGray5
                    }
                } else if let name = cardDict["name"] as? String {
                    iv.image = UIImage(named: name) ?? UIImage(named: "card_back")
                } else {
                    iv.image = UIImage(named: "card_back")
                }

                // Handle upright/reverse rotation
                if let isUpright = cardDict["isUpright"] as? Bool {
                    iv.transform = isUpright ? .identity : CGAffineTransform(rotationAngle: .pi)
                } else {
                    iv.transform = .identity
                }
            }
            // clear remaining
            if cards.count < cardImageViews.count {
                for idx in cards.count..<cardImageViews.count { cardImageViews[idx].image = nil; cardImageViews[idx].backgroundColor = UIColor.systemGray5 }
            }
        } else {
            for iv in cardImageViews { iv.image = nil; iv.backgroundColor = UIColor.systemGray5; iv.transform = .identity }
        }
    }

    // ripple effect when tapping arrow
    @objc private func arrowTapped(_ sender: UIButton) {
        // local point in container coordinates
        let centerPoint = sender.center
        let ripple = CALayer()
        let diameter: CGFloat = max(container.bounds.width, container.bounds.height) * 0.2
        ripple.bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ripple.position = centerPoint
        ripple.cornerRadius = diameter / 2
        ripple.backgroundColor = UIColor.white.withAlphaComponent(0.12).cgColor
        container.layer.addSublayer(ripple)

        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.2
        scale.toValue = 2.2
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 1.0
        fade.toValue = 0.0
        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 0.45
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        group.delegate = AnimationCleanupDelegate { [weak ripple] in ripple?.removeFromSuperlayer() }
        ripple.add(group, forKey: "ripple")
        // subtle press animation on container
        UIView.animate(withDuration: 0.18, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.995, y: 0.995)
        }) { _ in
            UIView.animate(withDuration: 0.22) { self.container.transform = .identity }
        }
    }

    func animateIn(delay: Double = 0) {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 8)
        UIView.animate(withDuration: 0.35, delay: delay, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.6, options: [.curveEaseOut], animations: {
            self.alpha = 1
            self.transform = .identity
        }, completion: nil)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let transform = highlighted ? CGAffineTransform(scaleX: 0.998, y: 0.998) : .identity
        let alpha: CGFloat = highlighted ? 0.92 : 1.0
        if animated {
            UIView.animate(withDuration: 0.18) {
                self.container.transform = transform
                self.container.alpha = alpha
            }
        } else {
            container.transform = transform
            container.alpha = alpha
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let transform = selected ? CGAffineTransform(scaleX: 0.995, y: 0.995) : .identity
        let alpha: CGFloat = selected ? 0.94 : 1.0
        if animated {
            UIView.animate(withDuration: 0.22) {
                self.container.transform = transform
                self.container.alpha = alpha
            }
        } else {
            container.transform = transform
            container.alpha = alpha
        }
    }
}

// Helper delegate to remove layer after CAAnimation finishes
private class AnimationCleanupDelegate: NSObject, CAAnimationDelegate {
    private let onComplete: () -> Void
    init(_ onComplete: @escaping () -> Void) { self.onComplete = onComplete }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) { onComplete() }
}
