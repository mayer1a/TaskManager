//
//  Task.swift
//  TaskManager
//
//  Created by Artem Mayer on 23.12.2022.
//

import Foundation

protocol Task {
    var title: String { get }
}

final class SubTask: Task {

    // MARK: - Properties

    var title: String

    // MARK: - Construction

    init(title: String) {
        self.title = title
    }

}

final class SuperTask: Task {

    // MARK: - Properties

    var title: String
    var subtasks: [Task]

    // MARK: - Construction

    init(title: String) {
        self.title = title
        self.subtasks = []
    }

}
