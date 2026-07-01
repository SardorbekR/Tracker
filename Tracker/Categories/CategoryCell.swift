//
//  CategoryCell.swift
//  Tracker
//
//  Created by Sardor on 7/1/26.
//

import UIKit

final class CategoryCell: UITableViewCell {
    // MARK: - Static Properties

    static let reuseIdentifier = "CategoryCell"

    // MARK: - Private Properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .ypGray)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(resource: .ypBackground)
        selectionStyle = .none
        tintColor = UIColor(resource: .ypBlue)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dividerView)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        accessoryType = .none
        dividerView.isHidden = false
    }

    // MARK: - Configuration

    func configure(title: String, isSelected: Bool, showDivider: Bool) {
        titleLabel.text = title
        accessoryType = isSelected ? .checkmark : .none
        dividerView.isHidden = !showDivider
    }
}
