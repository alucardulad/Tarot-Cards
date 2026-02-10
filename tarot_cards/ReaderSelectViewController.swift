//
//  ReaderSelectViewController.swift
//  tarot_cards
//
//  占卜师选择页面
//
//  ReaderSelectViewController.swift
//  tarot_cards
//
//  占卜师选择页面
//  Created by 陈柔 & 老萨满
//  Date: 2026-02-08
//

import UIKit

class ReaderSelectViewController: UIViewController {

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(ReaderCell.self, forCellReuseIdentifier: "ReaderCell")
        return tv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择你的占卜师"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "每个占卜师都有独特的风格，找到最适合你的那个吧~"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = UIColor(hex: "A5F2FF")
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBackgroundEffects()

        // 应用当前主题
        applyCurrentTheme()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .clear

        // 标题区域
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = ThemeManager.shared.primaryGradientStart
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true

        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])

        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 140)
        ])

        // 表格
        tableView.backgroundColor = UIColor.clear
        tableView.layer.opacity = 0.9
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBackgroundEffects() {
        // 根据当前选择的占卜师设置背景色
        let selectedReaderId = UserDefaults.standard.string(forKey: "selectedReaderId") ?? "reader_chenrou"
        let reader = ReaderManager.shared.getReader(id: selectedReaderId) ?? ReaderManager.shared.defaultReader

        // 根据占卜师使用不同的渐变色
        let gradientColors: [CGColor]
        switch reader.style.type {
        case .gentle:
            // 温柔导师型 - 紫色系
            gradientColors = [
                UIColor(hex: "7D3FE1").cgColor,
                UIColor(hex: "A5F2FF").cgColor,
                UIColor(hex: "7D3FE1").cgColor
            ]
        case .mysterious:
            // 神秘大师型 - 深紫色系
            gradientColors = [
                UIColor(hex: "2D1344").cgColor,
                UIColor(hex: "1E1233").cgColor,
                UIColor(hex: "120632").cgColor
            ]
        case .casual:
            // 星语型 - 粉金色系
            gradientColors = [
                UIColor(hex: "FF6B9D").cgColor,
                UIColor(hex: "FFD700").cgColor,
                UIColor(hex: "FF6B9D").cgColor
            ]
        case .oriental:
            // 月影型 - 蓝紫色系
            gradientColors = [
                UIColor(hex: "4A00E0").cgColor,
                UIColor(hex: "8E2DE2").cgColor,
                UIColor(hex: "4A00E0").cgColor
            ]
        default:
            // 其它未显式列出的风格使用占卜师主色做简单渐变
            gradientColors = [
                reader.primaryColor.withAlphaComponent(0.9).cgColor,
                reader.secondaryColor.withAlphaComponent(0.9).cgColor
            ]
        }

        let gradient = CAGradientLayer()
        gradient.colors = gradientColors
        gradient.locations = [0, 0.5, 1]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)

        // 星空粒子效果
        ParticleManager.addFullEffects(to: view)

        // 呼吸光晕效果 - 使用占卜师的配色
        ParticleManager.addBreathingOrbs(to: view, count: 5, colors: [reader.primaryColor.cgColor])
    }

    // MARK: - Actions

    private func toggleFavoriteReader(_ reader: TarotReader) {
        if ReaderManager.shared.isFavoriteReader(id: reader.id) {
            ReaderManager.shared.removeFavoriteReader(id: reader.id)
        } else {
            ReaderManager.shared.addFavoriteReader(id: reader.id)
        }

        // 刷新表格
        tableView.reloadData()

        // 刷新收藏按钮的样式
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let cell = tableView.cellForRow(at: selectedIndexPath) as? ReaderCell
            if let cell = cell {
                let reader = ReaderManager.shared.allReaders[selectedIndexPath.row]
                cell.configure(with: reader, isSelected: false, isFavorite: ReaderManager.shared.isFavoriteReader(id: reader.id))
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ReaderSelectViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReaderManager.shared.allReaders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReaderCell", for: indexPath) as? ReaderCell else {
            return UITableViewCell()
        }

        let reader = ReaderManager.shared.allReaders[indexPath.row]
        let isFavorite = ReaderManager.shared.isFavoriteReader(id: reader.id)
        cell.configure(with: reader, isSelected: false, isFavorite: isFavorite)
        cell.setupCallbacks(for: self)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ReaderSelectViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let reader = ReaderManager.shared.allReaders[indexPath.row]
        didSelectReader(reader)

        // 刷新收藏按钮的样式
        if let cell = tableView.cellForRow(at: indexPath) as? ReaderCell {
            let isFavorite = ReaderManager.shared.isFavoriteReader(id: reader.id)
            cell.configure(with: reader, isSelected: false, isFavorite: isFavorite)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    // MARK: - 选择占卜师

    private func didSelectReader(_ reader: TarotReader) {
        // 保存选择的占卜师
        ThemeManager.shared.saveCurrentReaderId(reader.id)

        // 通知所有 ViewController 主题已更新
        NotificationCenter.default.post(name: .themeDidChange, object: nil)

        // 返回结果
        navigationController?.popViewController(animated: true)
    }

    // MARK: - 应用当前主题

    private func applyCurrentTheme() {
        // 加载保存的占卜师
        ThemeManager.shared.loadSavedReaderId()

        // 刷新表格
        tableView.reloadData()
    }
}

// MARK: - ReaderCell

class ReaderCell: UITableViewCell {

    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(hex: "7D3FE1").cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var tagsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "A5F2FF")
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(hex: "CCCCCC")
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("选择", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(hex: "7D3FE1").cgColor
        button.backgroundColor = UIColor(hex: "7D3FE1").withAlphaComponent(0.3)
        button.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = UIColor(hex: "CCCCCC")
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Delegate reference
    weak var delegate: ReaderCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(style: .default, reuseIdentifier: "ReaderCell")
        setupUI()
    }

    private func setupUI() {
        // 允许表格选中
        selectionStyle = .blue

        contentView.addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(tagsLabel)
        containerView.addSubview(bioLabel)
        contentView.addSubview(selectButton)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            containerView.heightAnchor.constraint(equalToConstant: 96),

            avatarImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 60),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            tagsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            tagsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            tagsLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            bioLabel.topAnchor.constraint(equalTo: tagsLabel.bottomAnchor, constant: 6),
            bioLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            bioLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            bioLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            selectButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            selectButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            selectButton.widthAnchor.constraint(equalToConstant: 80),
            selectButton.heightAnchor.constraint(equalToConstant: 44),

            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: selectButton.leadingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    func configure(with reader: TarotReader, isSelected: Bool, isFavorite: Bool) {
        nameLabel.text = reader.name
        tagsLabel.text = reader.tags.joined(separator: " ")
        bioLabel.text = reader.bio

        // 应用占卜师的专属配色
        let primaryColor = reader.primaryColor
        let secondaryColor = reader.secondaryColor

        // 设置卡片容器的背景色
        containerView.backgroundColor = primaryColor.withAlphaComponent(0.2)

        // 根据选择状态更新样式
        if isSelected {
            containerView.layer.borderColor = secondaryColor.cgColor
            selectButton.backgroundColor = secondaryColor
            selectButton.setTitleColor(primaryColor, for: .normal)
        } else {
            containerView.layer.borderColor = primaryColor.cgColor
            selectButton.backgroundColor = primaryColor.withAlphaComponent(0.3)
            selectButton.setTitleColor(secondaryColor, for: .normal)
        }

        // 收藏按钮状态
        if isFavorite {
            favoriteButton.tintColor = reader.primaryColor
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favoriteButton.tintColor = UIColor(hex: "CCCCCC")
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }

    @objc private func selectButtonTapped() {
        delegate?.didSelectReaderAction(name: nameLabel.text ?? "")
    }

    @objc private func favoriteButtonTapped() {
        let readerName = nameLabel.text ?? ""
        delegate?.didFavoriteReaderAction(name: readerName)
    }
}

// MARK: - ReaderSelectViewController Delegate

protocol ReaderCellDelegate: AnyObject {
    func didSelectReaderAction(name: String)
    func didFavoriteReaderAction(name: String)
}

extension ReaderSelectViewController: ReaderCellDelegate {
    func didSelectReaderAction(name: String) {
        guard let reader = ReaderManager.shared.allReaders.first(where: { $0.name == name }) else { return }
        didSelectReader(reader)
    }

    func didFavoriteReaderAction(name: String) {
        guard let reader = ReaderManager.shared.allReaders.first(where: { $0.name == name }) else { return }
        toggleFavoriteReader(reader)
    }
}

extension ReaderCell {
    func setupCallbacks(for delegate: ReaderCellDelegate) {
        self.delegate = delegate
    }
}
