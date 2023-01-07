//
//  MainTasksMenuViewController.swift
//  TaskManager
//
//  Created by Artem Mayer on 22.12.2022.
//

import UIKit

final class MainTasksMenuViewController: UIViewController {

    // MARK: - Private properties

    private var tasksCount: Int = 0
    private var selectedSuperTaskNumber: Int = 0
    private var addedTasks: [Task] = [] {
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

        setupTask()

        mainTaskView?.delegate = self
        mainTaskView?.dataSource = self

        mainTaskView?.register(MainTaskTableViewCell.self, forCellReuseIdentifier: MainTaskTableViewCell.cellId)

        configureNavigationBar()
    }

    // MARK: - Private functions

    private func configureNavigationBar() {
        if navigationController?.viewControllers.first !== self {
            guard let backBarButton = mainTaskView?.backBarButton else { return }

            backBarButton.addTarget(self, action: #selector(returnSubtasks), for: .touchUpInside)

            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
        } else {
            navigationItem.leftBarButtonItem = nil
        }

        navigationItem.rightBarButtonItem = mainTaskView?.addTaskBarButton

        if tasksCount == 1, addedTasks.first?.title.isEmpty == true {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    private func setupTask() {
        if addedTasks.isEmpty {
            addedTasks.append(SubTask(title: ""))
        }
    }

    private func addedSubtasksToSuperTask(_ subtasks: [Task]) {
        if let superTask = addedTasks[selectedSuperTaskNumber] as? SuperTask {
            superTask.subtasks = subtasks
        } else {
            let superTask = SuperTask(title: addedTasks[selectedSuperTaskNumber].title)
            superTask.subtasks.append(contentsOf: subtasks)

            addedTasks[selectedSuperTaskNumber] = superTask
        }
    }

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
            let row = mainTaskView?.indexPath(for: cell)?.row,
            let text = textField.text,
            addedTasks[row].title != text
        else {
            return
        }

        addedTasks[row] = SubTask(title: text)
    }

    private func resignFirstResponderIfNeeded() {
        for cellNumber in 0..<tasksCount {
            let cell = mainTaskView?.cellForRow(at: IndexPath(row: cellNumber, section: 0))
            (cell as? MainTaskTableViewCell)?.taskTextField.resignFirstResponder()
        }

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

    @objc private func returnSubtasks() {
        resignFirstResponderIfNeeded()

        navigationController?.popViewController(animated: true)

        guard
            let previousViewController = navigationController?.topViewController as? MainTasksMenuViewController,
            previousViewController !== self
        else {
            return
        }

        previousViewController.addedSubtasksToSuperTask(addedTasks)
    }

}

// MARK: - Extensions

extension MainTasksMenuViewController: AddTaskTableViewDelegate {

    func addTaskButtonDidTapped() {
        addedTasks.append(SubTask(title: ""))
        
        mainTaskView?.beginUpdates()
        mainTaskView?.insertRows(at: [IndexPath(row: tasksCount - 1, section: 0)], with: .automatic)
        mainTaskView?.endUpdates()

        navigationItem.rightBarButtonItem?.isEnabled = false
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

        cell.configureTaskTextField(with: addedTasks[indexPath.row].title)
        cell.taskTextField.delegate = self
        cell.taskCheckButton.addTarget(self, action: #selector(taskCompletedButtonTapped(_:)), for: .touchUpInside)

        if indexPath.row == tasksCount - 1, !cell.taskTextField.hasText {
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
        selectedSuperTaskNumber = indexPath.row

        let nextTaskViewController = MainTasksMenuViewController()

        if let selectTask = addedTasks[indexPath.row] as? SuperTask {
            nextTaskViewController.addedTasks = selectTask.subtasks
        }
        (tableView.cellForRow(at: indexPath) as? MainTaskTableViewCell)?.taskTextField.resignFirstResponder()
        navigationController?.pushViewController(nextTaskViewController, animated: true)
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
