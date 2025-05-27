//
//  CalendarViewController.swift
//  TaskManager
//
//  Created by Santosh Singh on 22/05/25.
//

import UIKit
import JTAppleCalendar

protocol CalendarViewControllerDelegate: AnyObject {
    func calendarViewController(_ controller: CalendarViewController, didSelectDate date: Date, tasks: [Task])
}

class CalendarViewController: UIViewController {
    weak var delegate: CalendarViewControllerDelegate?

    // MARK: - UI Components

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let weekdaysStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var selectedTasks: [Task] = []

    private let taskTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableView.tableFooterView = UIView()
        return tableView
    }()

    let calendarView: JTACMonthView = {
        let calendar = JTACMonthView()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.scrollDirection = .horizontal
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.showsHorizontalScrollIndicator = false
        calendar.minimumLineSpacing = 0
        calendar.minimumInteritemSpacing = 0
        calendar.allowsSelection = true
        calendar.allowsMultipleSelection = false
        return calendar
    }()

    // MARK: - Data

    var tasksByDate: [String: [Task]] = [:] {
        didSet {
            selectedTasks.removeAll()
            taskTableView.isHidden = true
            taskTableView.reloadData()
        }
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupWeekdaysHeader()
        setupViews()

        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")

        taskTableView.dataSource = self
        taskTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")

        // Set initial month label
        let today = Date()
        monthLabel.text = formattedMonth(today)
    }

    // MARK: - Setup

    private func setupWeekdaysHeader() {
        let formatter = DateFormatter()
        var weekdaySymbols = formatter.shortStandaloneWeekdaySymbols! // ["Sun", "Mon", ...]

        // Shift to Monday first if your locale uses Monday as first day
        let firstWeekday = Calendar.current.firstWeekday // 1=Sunday, 2=Monday ...
        if firstWeekday == 2 {
            let sunday = weekdaySymbols.removeFirst()
            weekdaySymbols.append(sunday)
        }

        for day in weekdaySymbols {
            let label = UILabel()
            label.text = day
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            weekdaysStackView.addArrangedSubview(label)
        }
    }

    private func setupViews() {
        view.addSubview(monthLabel)
        view.addSubview(weekdaysStackView)
        view.addSubview(calendarView)
        view.addSubview(taskTableView)
        taskTableView.isHidden = true

        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            monthLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            monthLabel.heightAnchor.constraint(equalToConstant: 40),

            weekdaysStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor),
            weekdaysStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            weekdaysStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            weekdaysStackView.heightAnchor.constraint(equalToConstant: 20),

            calendarView.topAnchor.constraint(equalTo: weekdaysStackView.bottomAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 300),

            taskTableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -2),
            taskTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            taskTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            taskTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Helpers

    private func formattedMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - JTACMonthViewDataSource/JTACMonthViewDelegate

extension CalendarViewController: JTACMonthViewDataSource, JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? CalendarCell else { return }
        cell.dateLabel.text = cellState.text
        let key = formattedDate(date)
        cell.dotView.isHidden = tasksByDate[key]?.isEmpty ?? true
    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2025 01 01")!
        let endDate = formatter.date(from: "2050 12 31")!
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }

    func calendar(_ calendar: JTACMonthView,
                  cellForItemAt date: Date,
                  cellState: CellState,
                  indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        cell.dateLabel.textColor = cellState.dateBelongsTo == .thisMonth ? .label : .secondaryLabel
        cell.dotView.isHidden = true

        let key = formattedDate(date)
        if let tasks = tasksByDate[key], !tasks.isEmpty {
            cell.dotView.isHidden = false
        }

        return cell
    }

    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if let date = visibleDates.monthDates.first?.date {
            monthLabel.text = formattedMonth(date)
        }
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        let key = formattedDate(date)
        if let tasks = tasksByDate[key], !tasks.isEmpty {
            selectedTasks = tasks
            taskTableView.reloadData()

            if taskTableView.isHidden {
                taskTableView.isHidden = false

                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            selectedTasks = []
            taskTableView.reloadData()

            if !taskTableView.isHidden {
                taskTableView.isHidden = true

                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        delegate?.calendarViewController(self, didSelectDate: date, tasks: selectedTasks)
    }
}

// MARK: - UITableViewDataSource

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = selectedTasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        let title = task.title
        let schedule = task.dueDate.toReadbleFormat()

        let fullText = "\(title)" + " | " + "\(schedule)"
        let attributedString = NSMutableAttributedString(string: fullText)

        // Title: default color (black)
        let titleRange = NSRange(location: 0, length: title.count)
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: titleRange)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .regular), range: titleRange)

        // Detail: gray color
        let detailRange = NSRange(location: title.count + 3, length: schedule.count)
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: detailRange)
        attributedString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 12), range: detailRange)

        cell.textLabel?.attributedText = attributedString

        return cell
    }

}
