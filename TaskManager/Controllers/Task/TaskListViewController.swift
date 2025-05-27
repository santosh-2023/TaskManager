//
//  TaskListViewController.swift
//  TaskManager
//
//  Created by Santosh Singh on 21/05/25.
//

import UIKit

class TaskListViewController: UIViewController {

    private var tasks: [Task] = []
    private let taskTableView = UITableView()

    // selected filter, set to all by default
    private var currentFilter: TaskFilter = .all

    // Lazy var to keep strong reference and allow resizing
    lazy var calendarVC: CalendarViewController = {
        let vc = CalendarViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: 300, height: 380)
        return vc
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No tasks yet.\nTap '+' to create one."
        label.textAlignment = .center
        label.backgroundColor = UIColor.systemGray5
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tasks"
        view.backgroundColor = .systemBackground

        setupTableView()
        setupEmptyStateLabel()
        taskTableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "TaskCell")

        configToolBarItems()
        fetchTasks()
    }

    private func configToolBarItems() {
        // Create buttons
        let addButton = makeToolbarButton(image: UIImage(systemName: "plus"), action: #selector(addTask))
        let calendarButton = makeToolbarButton(image: UIImage(systemName: "calendar.badge.clock"), action: #selector(openCalendarTapped))
        let filterButton = makeToolbarButton(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), action: #selector(filterButtonTapped))

        // Create stack view
        let stackView = UIStackView(arrangedSubviews: [filterButton, calendarButton, addButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center

        // Wrap stackView in UIBarButtonItem
        let customBarButtonItem = UIBarButtonItem(customView: stackView)
        navigationItem.rightBarButtonItem = customBarButtonItem
    }

    // Helper function to create a UIButton for the toolbar
    private func makeToolbarButton(image: UIImage?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }


    private func setupTableView() {
        view.addSubview(taskTableView)
        taskTableView.translatesAutoresizingMaskIntoConstraints = false
        taskTableView.separatorStyle = .none
        taskTableView.backgroundColor = .systemGroupedBackground
        taskTableView.rowHeight = UITableView.automaticDimension
        taskTableView.estimatedRowHeight = 200

        NSLayoutConstraint.activate([
            taskTableView.topAnchor.constraint(equalTo: view.topAnchor),
            taskTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            taskTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
    }

    private func setupEmptyStateLabel() {
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.widthAnchor.constraint(equalToConstant: 200),
            emptyStateLabel.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func fetchTasks() {
        tasks = Task.fetchAll()
        self.taskTableView.reloadData()
        self.emptyStateLabel.isHidden = !self.tasks.isEmpty
    }

    @objc func addTask() {
        let vc = TaskEditViewController()
        vc.onSave = { [weak self] in self?.fetchTasks() }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func openCalendarTapped(_ sender: UIBarButtonItem) {
        calendarVC.tasksByDate = generateTasksByDate()

        if let popover = calendarVC.popoverPresentationController {
            popover.barButtonItem = sender
            popover.permittedArrowDirections = [.up, .down]
            popover.delegate = self
        }

        present(calendarVC, animated: true, completion: nil)
    }

    @objc func filterButtonTapped(_ sender: UIBarButtonItem) {
        let filterVC = FilterPopoverViewController(selectedFilter: currentFilter)
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .popover

        if let popover = filterVC.popoverPresentationController {
            popover.barButtonItem = sender
            popover.permittedArrowDirections = .up
            popover.delegate = self
        }

        present(filterVC, animated: true)
    }

    func generateTasksByDate() -> [String: [Task]] {
        var dict: [String: [Task]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for task in tasks {
            let dateKey = formatter.string(from: task.dueDate)
            dict[dateKey, default: []].append(task)
        }

        return dict
    }
    
}


// MARK: - UITableViewDataSource

extension TaskListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: task)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let taskDetailVC = TaskDetailViewController(task: task)
        taskDetailVC.onStatusChanged = { [weak self] in self?.fetchTasks() }
        self.navigationController?.pushViewController(taskDetailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToBeDeleted = tasks[indexPath.row]
            taskToBeDeleted.delete()
            NotificationManager.shared.deleteNotification(for: taskToBeDeleted)
            fetchTasks()
        }
    }

    // Add vertical spacing between cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension TaskListViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.calendarVC.preferredContentSize = CGSize(width: 300, height: 380)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // This forces popover style on iPhone instead of defaulting to full screen
        return .none
    }
}

extension TaskListViewController: CalendarViewControllerDelegate {
    func calendarViewController(_ controller: CalendarViewController, didSelectDate date: Date, tasks: [Task]) {
        UIView.animate(withDuration: 0.2) {
            let defaultTableHeight = 380
            let count = min(tasks.count, 3)
            let tableViewOffSet = count * 30
            self.calendarVC.preferredContentSize = CGSize(width: 300, height: tasks.count > 0 ? (defaultTableHeight + tableViewOffSet) : defaultTableHeight)
        }
    }
}

extension TaskListViewController: FilterPopoverDelegate {
    func didSelectFilter(_ filter: TaskFilter) {
        currentFilter = filter
        tasks = Task.fetchAll()
        tasks = filterAndSortTasks(self.tasks, with: filter)
        taskTableView.reloadData()
    }

    func filterAndSortTasks(_ tasks: [Task], with filter: TaskFilter) -> [Task] {
        let filteredTasks: [Task]

        switch filter {
            case .all:
                filteredTasks = tasks
            case .incomplete:
                filteredTasks = tasks.filter { !$0.isCompleted }
            case .completed:
                filteredTasks = tasks.filter { $0.isCompleted }
        }

        // Sort by due date ascending
        return filteredTasks.sorted(by: { $0.dueDate < $1.dueDate })
    }
}

extension TaskListViewController: TaskTableViewCellDelegate {
    func taskCellDidTapEdit(_ cell: TaskTableViewCell) {
        guard let indexPath = taskTableView.indexPath(for: cell) else { return }
        let vc = TaskEditViewController(task: tasks[indexPath.row])
        vc.onSave = { [weak self] in self?.fetchTasks() }
        navigationController?.pushViewController(vc, animated: true)
    }

    func taskCellDidTapDetail(_ cell: TaskTableViewCell) {
        guard let indexPath = taskTableView.indexPath(for: cell) else { return }
        let task = tasks[indexPath.row]
        let taskDetailVC = TaskDetailViewController(task: task)
        taskDetailVC.onStatusChanged = { [weak self] in self?.fetchTasks() }
        self.navigationController?.pushViewController(taskDetailVC, animated: true)
    }
}

