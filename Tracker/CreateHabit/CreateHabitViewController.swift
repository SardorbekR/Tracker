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

    private let placeholderEmojis = ["❤️", "😻", "🌺", "😇", "😍", "🥶", "🤔", "🙂", "🐶"]
    private let placeholderColors: [UIColor] = [
        .systemRed, .systemOrange, .systemBlue, .systemGreen, .systemPurple, .systemPink
    ]

    private var scheduleSummary: String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == Weekday.allCases.count {
            return "Каждый день"
        }
        return selectedSchedule.map { $0.shortTitle }.joined(separator: ", ")
    }

    // MARK: - UI Elements

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
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(fieldStackView)
        view.addSubview(optionsTableView)
        view.addSubview(buttonsStackView)
        NSLayoutConstraint.activate([
            fieldStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            fieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            optionsTableView.topAnchor.constraint(equalTo: fieldStackView.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),

            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Private Methods

    private func updateCreateButtonState() {
        let text = nameTextField.text ?? ""
        let trimmedName = text.trimmingCharacters(in: .whitespaces)
        let isValidName = !trimmedName.isEmpty && text.count <= nameLengthLimit
        let isEnabled = isValidName && !selectedSchedule.isEmpty
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }

    // MARK: - Actions

    @objc private func nameChanged() {
        errorLabel.isHidden = (nameTextField.text ?? "").count <= nameLengthLimit
        updateCreateButtonState()
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func didTapCreate() {
        let name = (nameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: placeholderColors.randomElement() ?? .systemBlue,
            emoji: placeholderEmojis.randomElement() ?? "❤️",
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

// MARK: - ScheduleViewControllerDelegate

extension CreateHabitViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ controller: ScheduleViewController, didSelect schedule: [Weekday]) {
        selectedSchedule = schedule
        optionsTableView.reloadData()
        updateCreateButtonState()
        navigationController?.popViewController(animated: true)
    }
}
