//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Sardor on 7/1/26.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    // MARK: - Public Properties

    var onDone: ((String) -> Void)?

    // MARK: - Private Properties

    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
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

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypGray)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Новая категория"
        setupLayout()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(nameTextField)
        view.addSubview(doneButton)
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        let restingBottom = doneButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -16
        )
        restingBottom.priority = .defaultLow
        restingBottom.isActive = true
    }

    // MARK: - Private Methods

    private func trimmedName() -> String {
        (nameTextField.text ?? "").trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Actions

    @objc private func nameChanged() {
        let isEnabled = !trimmedName().isEmpty
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled ? UIColor(resource: .ypBlack) : UIColor(resource: .ypGray)
    }

    @objc private func didTapDone() {
        let name = trimmedName()
        guard !name.isEmpty else { return }
        onDone?(name)
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
