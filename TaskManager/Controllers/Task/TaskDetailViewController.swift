//
//  TaskDetailViewController.swift
//  TaskManager
//
//  Created by Santosh Singh on 21/05/25.
//

import UIKit

class TaskDetailViewController: UIViewController {

    let selectedTask: Task
    var onStatusChanged: (() -> Void)?

    // UI Elements
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let dueDateLabel = UILabel()
    private let priorityLabel = UILabel()
    private let statusLabel = UILabel()
    private let toggleStatusButton = UIButton(type: .system)

    init(task: Task) {
        self.selectedTask = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Task Details"

        setupUI()
        populateData()
    }

    private func setupUI() {
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0

        descLabel.font = .systemFont(ofSize: 16)
        descLabel.numberOfLines = 0
        descLabel.textColor = .secondaryLabel

        dueDateLabel.font = .systemFont(ofSize: 16)
        priorityLabel.font = .systemFont(ofSize: 16)
        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textColor = .label

        toggleStatusButton.addTarget(self, action: #selector(toggleTaskStatus), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            descLabel,
            dueDateLabel,
            priorityLabel,
            statusLabel,
            toggleStatusButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func populateData() {
        titleLabel.text = selectedTask.title
        descLabel.text = selectedTask.taskDescription
        dueDateLabel.text = "Due: \(selectedTask.dueDate.formatted(date: .abbreviated, time: .shortened))"
        priorityLabel.text = "Priority: \(priorityDescription(for: selectedTask.priority))"
        statusLabel.text = "Status: " + (selectedTask.isCompleted ? "Completed" : "In Progress")
        toggleStatusButton.setTitle(selectedTask.isCompleted ? "Mark as Incomplete" : "Mark as Completed", for: .normal)
    }

    private func priorityDescription(for level: Int16) -> String {
        switch level {
            case 0: return "Low"
            case 1: return "Medium"
            case 2: return "High"
            default: return "Unknown"
        }
    }

    @objc private func toggleTaskStatus() {
        selectedTask.isCompleted.toggle()
        CoreDataManager.shared.save()
        populateData()

        let message = selectedTask.isCompleted ? "Task marked as completed." : "Task marked as incomplete."
        let alert = UIAlertController(title: "Status Updated", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.onStatusChanged?()
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

