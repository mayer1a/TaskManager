//
//  MainTaskTableViewCell.swift
//  TaskManager
//
//  Created by Artem Mayer on 22.12.2022.
//

import UIKit

final class MainTaskTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let cellId = "MainTaskCellId"

    // MARK: - Private properties

    let taskTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .left
        textField.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        textField.textColor = .label
        textField.backgroundColor = .systemBackground
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = UIColor.systemBackground.cgColor
        textField.layer.borderWidth = 1
        textField.layer.masksToBounds = true
        textField.clipsToBounds = true
        textField.clearButtonMode = .whileEditing
        textField.minimumFontSize = 20.0
        textField.autocorrectionType = .yes
        textField.spellCheckingType = .yes
        textField.placeholder = "Enter your next task ..."
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }()

    let taskCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBackground
        button.tintColor = .tertiaryLabel
        button.setImage(.init(systemName: "circle"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    // MARK: - Constructions

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        configureViewComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()

        taskTextField.text = ""
        taskCheckButton.setImage(.init(systemName: "circle"), for: .normal)
        taskCheckButton.tintColor = .tertiaryLabel
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Functions

    func configureTaskTextField(with text: String?) {
        self.taskTextField.text = text
    }

    // MARK: - Private functions

    private func configureViewComponents() {
        selectionStyle = .none
        contentView.backgroundColor = .systemBackground
        backgroundColor = .systemBackground
        contentMode = .center
        accessoryType = .detailButton
        tintColor = .systemBlue
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 70)
        
        contentView.addSubview(taskTextField)
        contentView.addSubview(taskCheckButton)

        NSLayoutConstraint.activate([
            taskCheckButton.trailingAnchor.constraint(equalTo: taskTextField.leadingAnchor, constant: -10),
            taskCheckButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            taskCheckButton.widthAnchor.constraint(equalTo: taskCheckButton.heightAnchor),
            taskCheckButton.centerYAnchor.constraint(equalTo: taskTextField.centerYAnchor),

            taskTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            taskTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            taskTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }

}
