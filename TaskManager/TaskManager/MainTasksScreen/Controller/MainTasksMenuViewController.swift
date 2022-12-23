//
//  MainTasksMenuViewController.swift
//  TaskManager
//
//  Created by Artem Mayer on 22.12.2022.
//

import UIKit

final class MainTasksMenuViewController: UIViewController {

    // MARK: - Private properties

    private var tasksCount: Int = 1
    private var addedTasks: [String?] = [""] {
        didSet {
            onSetupNewValue()
        }
    }

    private var mainTaskView: MainTaskView? {
        return isViewLoaded ? view as? MainTaskView : nil
    }

    // MARK: - Lifecycle

    override func loadView() {
        self.view = MainTaskView(addTaskTableViewDelegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mainTaskView?.delegate = self
        mainTaskView?.dataSource = self

        mainTaskView?.register(MainTaskTableViewCell.self, forCellReuseIdentifier: MainTaskTableViewCell.cellId)

        navigationItem.rightBarButtonItem = mainTaskView?.addTaskBarButton
    }

    // MARK: - Private functions

    private func onSetupNewValue() {
        tasksCount = addedTasks.count

        (mainTaskView?.tableHeaderView as? UILabel)?.text = "Tasks count: \(tasksCount)"
    }

    private func removeCompletedTask(at cell: MainTaskTableViewCell) {
        guard
            let indexPath = mainTaskView?.indexPath(for: cell)
        else {
            return
        }

        addedTasks.remove(at: indexPath.row)

        mainTaskView?.beginUpdates()
        mainTaskView?.deleteRows(at: [indexPath], with: .automatic)
        mainTaskView?.endUpdates()

        if tasksCount < 1 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }

    private func appendTask(from textField: UITextField) {
        guard
            let cell = textField.superview?.superview as? MainTaskTableViewCell,
            let row = mainTaskView?.indexPath(for: cell)?.row
        else {
            return
        }

        addedTasks[row] = textField.text
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    @objc private func taskCompletedButtonTapped(_ sender: UIButton) {
        guard
            let cell = sender.superview?.superview as? MainTaskTableViewCell
        else {
            return
        }

        cell.taskTextField.resignFirstResponder()
        
        if sender.tintColor == .systemGreen {
            sender.setImage(.init(systemName: "circle"), for: .normal)
            sender.tintColor = .tertiaryLabel
        } else {
            sender.setImage(.init(systemName: "checkmark.circle.fill"), for: .normal)
            sender.tintColor = .systemGreen
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.removeCompletedTask(at: cell)
        }
    }

}

// MARK: - Extensions

extension MainTasksMenuViewController: AddTaskTableViewDelegate {

    func addTaskButtonDidTapped() {
        addedTasks.append("")
        
        mainTaskView?.beginUpdates()
        mainTaskView?.insertRows(at: [IndexPath(row: tasksCount - 1, section: 0)], with: .automatic)
        mainTaskView?.endUpdates()
    }
}

extension MainTasksMenuViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksCount
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: MainTaskTableViewCell.cellId, for: indexPath)

        guard let cell = reusableCell as? MainTaskTableViewCell else { return UITableViewCell() }

        cell.configureTaskTextField(with: addedTasks[indexPath.row])
        cell.taskTextField.delegate = self
        cell.taskCheckButton.addTarget(self, action: #selector(taskCompletedButtonTapped(_:)), for: .touchUpInside)

        if tasksCount > 1, indexPath.row == tasksCount - 1 {
            cell.taskTextField.becomeFirstResponder()
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        navigationController?.pushViewController(MainTasksMenuViewController(), animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

}

extension MainTasksMenuViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if reason == .committed {
            appendTask(from: textField)
        }
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = textField.hasText
    }
}
