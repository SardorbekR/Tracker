//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Sardor on 6/27/26.
//

import UIKit

protocol CreateHabitViewControllerDelegate: AnyObject {
    func createHabitViewController(_ controller: CreateHabitViewController, didCreate tracker: Tracker)
}

final class CreateHabitViewController: UIViewController {
    // MARK: - Public Properties

    weak var delegate: CreateHabitViewControllerDelegate?

    // MARK: - Private Properties

    private let options = ["Категория", "Расписание"]
    private let nameLengthLimit = 38
    private var selectedSchedule: [Weekday] = []

    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    private let colors: [UIColor] = [
        UIColor(resource: .colorSelection1), UIColor(resource: .colorSelection2),
        UIColor(resource: .colorSelection3), UIColor(resource: .colorSelection4),
        UIColor(resource: .colorSelection5), UIColor(resource: .colorSelection6),
        UIColor(resource: .colorSelection7), UIColor(resource: .colorSelection8),
        UIColor(resource: .colorSelection9), UIColor(resource: .colorSelection10),
        UIColor(resource: .colorSelection11), UIColor(resource: .colorSelection12),
        UIColor(resource: .colorSelection13), UIColor(resource: .colorSelection14),
        UIColor(resource: .colorSelection15), UIColor(resource: .colorSelection16),
        UIColor(resource: .colorSelection17), UIColor(resource: .colorSelection18)
    ]

    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    private var scheduleSummary: String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == Weekday.allCases.count {
            return "Каждый день"
        }
        return selectedSchedule.map { $0.shortTitle }.joined(separator: ", ")
    }

    // MARK: - UI Elements

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(resource: .ypBackground)
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(resource: .ypRed)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var fieldStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, errorLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(OptionCell.self, forCellReuseIdentifier: OptionCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var emojiHeaderLabel = makeSectionHeaderLabel(title: "Emoji")

    private lazy var emojiCollectionView: UICollectionView = {
        let collectionView = makeGridCollectionView()
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var colorHeaderLabel = makeSectionHeaderLabel(title: "Цвет")

    private lazy var colorCollectionView: UICollectionView = {
        let collectionView = makeGridCollectionView()
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(resource: .ypRed), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .ypRed).cgColor
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypGray)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Новая привычка"
        setupLayout()
        setupKeyboardDismiss()
    }

    // MARK: - Setup

    private func setupLayout() {
        addSubviews()
        setupConstraints()
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [
            fieldStackView,
            optionsTableView,
            emojiHeaderLabel,
            emojiCollectionView,
            colorHeaderLabel,
            colorCollectionView,
            buttonsStackView
        ].forEach { contentView.addSubview($0) }
    }

    private func setupConstraints() {
        let contentLayout = scrollView.contentLayoutGuide
        let frameLayout = scrollView.frameLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: contentLayout.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayout.widthAnchor),

            fieldStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            fieldStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            fieldStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            optionsTableView.topAnchor.constraint(equalTo: fieldStackView.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),

            emojiHeaderLabel.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            emojiHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiHeaderLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 156),

            colorHeaderLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 40),
            colorHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            colorCollectionView.topAnchor.constraint(equalTo: colorHeaderLabel.bottomAnchor, constant: 24),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 156),

            buttonsStackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }

    private func makeSectionHeaderLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeGridCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }

    // MARK: - Private Methods

    private func updateCreateButtonState() {
        let text = nameTextField.text ?? ""
        let trimmedName = text.trimmingCharacters(in: .whitespaces)
        let isValidName = !trimmedName.isEmpty && text.count <= nameLengthLimit
        let isEnabled = isValidName
            && !selectedSchedule.isEmpty
            && selectedEmoji != nil
            && selectedColor != nil
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }

    // MARK: - Actions

    @objc private func nameChanged() {
        errorLabel.isHidden = (nameTextField.text ?? "").count <= nameLengthLimit
        updateCreateButtonState()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func didTapCreate() {
        let name = (nameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard let emoji = selectedEmoji, let color = selectedColor else { return }
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: selectedSchedule
        )
        delegate?.createHabitViewController(self, didCreate: tracker)
    }
}

// MARK: - UITextFieldDelegate

extension CreateHabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource

extension CreateHabitViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: OptionCell.reuseIdentifier,
            for: indexPath
        ) as? OptionCell else {
            return UITableViewCell()
        }
        let isScheduleRow = indexPath.row == 1
        let isLastRow = indexPath.row == options.count - 1
        cell.configure(
            title: options[indexPath.row],
            subtitle: isScheduleRow ? scheduleSummary : nil,
            showDivider: !isLastRow
        )
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CreateHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 1 else { return }
        let scheduleViewController = ScheduleViewController(selectedWeekdays: selectedSchedule)
        scheduleViewController.delegate = self
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension CreateHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView === emojiCollectionView ? emojis.count : colors.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView === emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCell else {
                return UICollectionViewCell()
            }
            cell.configure(emoji: emojis[indexPath.item])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCell else {
                return UICollectionViewCell()
            }
            cell.configure(color: colors[indexPath.item])
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 52, height: 52)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        let columns: CGFloat = 6
        let cellWidth: CGFloat = 52
        let spacing = (collectionView.bounds.width - columns * cellWidth) / (columns - 1)
        return max(spacing, 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
        } else {
            selectedColor = colors[indexPath.item]
        }
        updateCreateButtonState()
    }
}

// MARK: - ScheduleViewControllerDelegate

extension CreateHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelect schedule: [Weekday]) {
        selectedSchedule = schedule
        optionsTableView.reloadData()
        updateCreateButtonState()
        navigationController?.popViewController(animated: true)
    }
}
