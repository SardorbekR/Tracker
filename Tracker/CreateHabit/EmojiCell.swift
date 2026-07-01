//
//  EmojiCell.swift
//  Tracker
//
//  Created by Sardor on 6/29/26.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    // MARK: - Static Properties

    static let reuseIdentifier = "EmojiCell"

    // MARK: - Private Properties

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(resource: .ypLightGray) : .clear
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        contentView.backgroundColor = .clear
    }

    // MARK: - Configuration

    func configure(emoji: String) {
        emojiLabel.text = emoji
    }
}
