//
//  ColorCell.swift
//  Tracker
//
//  Created by Sardor on 6/29/26.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    // MARK: - Static Properties

    static let reuseIdentifier = "ColorCell"

    // MARK: - Private Properties

    private var color: UIColor = .clear

    private lazy var selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectionView)
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 46),
            selectionView.heightAnchor.constraint(equalToConstant: 46),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            selectionView.isHidden = !isSelected
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = nil
        selectionView.isHidden = true
    }

    // MARK: - Configuration

    func configure(color: UIColor) {
        self.color = color
        colorView.backgroundColor = color
        selectionView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
}
