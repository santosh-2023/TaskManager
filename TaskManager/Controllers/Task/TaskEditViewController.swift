//
//  TaskEditViewController.swift
//  TaskManager
//
//  Created by Santosh Singh on 21/05/25.
//

import UIKit

class TaskEditViewController: UIViewController {

    var task: Task?
    var onSave: (() -> Void)?

    private let titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Title"
        field.borderStyle = .roundedRect
        return field
    }()

    private let descField: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        return textView
    }()

    private let descPlaceholder = "Description (optional)"
    private var isShowingPlaceholder = true

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .compact
        return picker
    }()

    private let prioritySegment = UISegmentedControl(items: ["Low", "Med", "High"])

    init(task: Task? = nil) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = task == nil ? "Add Task" : "Edit Task"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTask)
        )

        descField.delegate = self

        let stack = UIStackView(arrangedSubviews: [titleField, descField, datePicker, prioritySegment])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descField.heightAnchor.constraint(equalToConstant: 100)
        ])

        configureView()
    }

    private func configureView() {
        if let task = task {
            titleField.text = task.title
            descField.text = task.taskDescription
            isShowingPlaceholder = descField.text.isEmpty
            if isShowingPlaceholder {
                setPlaceholder()
            }
            datePicker.date = task.dueDate
            prioritySegment.selectedSegmentIndex = Int(task.priority)
        } else {
            setPlaceholder()
            prioritySegment.selectedSegmentIndex = 0
        }
    }

    private func setPlaceholder() {
        descField.text = descPlaceholder
        descField.textColor = .placeholderText
        isShowingPlaceholder = true
    }

    @objc private func saveTask() {
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var desc = descField.text ?? ""
        if isShowingPlaceholder {
            desc = ""
        }
        let date = datePicker.date
        let priority = Int16(prioritySegment.selectedSegmentIndex)

        guard !title.isEmpty else {
            let alert = UIAlertController(title: "Missing Title", message: "Please enter a task title.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        if let task = task {
           let updatedTask = task.update(title: title, desc: desc, dueDate: date, priority: priority)
            NotificationManager.shared.updateNotification(for: updatedTask)
        } else {
            let newTask = Task.create(title: title, desc: desc, dueDate: date, priority: priority)
            NotificationManager.shared.scheduleNotification(for: newTask)
        }

        onSave?()
        navigationController?.popViewController(animated: true)
    }
}

extension TaskEditViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isShowingPlaceholder {
            textView.text = ""
            textView.textColor = .label
            isShowingPlaceholder = false
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setPlaceholder()
        }
    }
}

