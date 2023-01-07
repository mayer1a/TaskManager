//
//  MainTaskView.swift
//  TaskManager
//
//  Created by Artem Mayer on 22.12.2022.
//

import UIKit

protocol AddTaskTableViewDelegate: AnyObject {
    func addTaskButtonDidTapped()
}

final class MainTaskView: UITableView {

    // MARK: - Properties

    weak var addTaskTableViewDelegate: AddTaskTableViewDelegate?

    let addTaskBarButton: UIBarButtonItem = {
        return UIBarButtonItem()
    }()

    let backBarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.init(systemName: "chevron.backward"), for: .normal)
        button.setTitle("Назад", for: .normal)
        button.sizeToFit()

        return button
    }()

    // MARK: - Construction

    init(addTaskTableViewDelegate: AddTaskTableViewDelegate?) {
        self.addTaskTableViewDelegate = addTaskTableViewDelegate

        super.init(frame: .zero, style: .insetGrouped)

        configureViewComponents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private functions

    private func configureViewComponents() {
        separatorStyle = .singleLine
        separatorColor = .systemGray
        backgroundColor = .systemBackground
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        let headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        headerLabel.textAlignment = .center
        headerLabel.textColor = .secondaryLabel

        tableHeaderView = headerLabel
        tableFooterView = UIView()

        addTaskBarButton.image = .init(systemName: "plus.circle")
        addTaskBarButton.style = .plain
        addTaskBarButton.target = self
        addTaskBarButton.action = #selector(addTaskButtonTapped(_:))
    }

    @objc private func addTaskButtonTapped(_ sender: UIBarButtonItem) {
        addTaskTableViewDelegate?.addTaskButtonDidTapped()
    }
}
