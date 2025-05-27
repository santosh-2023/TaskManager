//
//  FilterPopoverViewController.swift
//  TaskManager
//
//  Created by Santosh Singh on 23/05/25.
//

import UIKit

protocol FilterPopoverDelegate: AnyObject {
    func didSelectFilter(_ filter: TaskFilter)
}

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case incomplete = "Incomplete"
    case completed = "Completed"
}

class FilterPopoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: FilterPopoverDelegate?
    private var selectedFilter: TaskFilter
    private let tableView = UITableView()
    
    init(selectedFilter: TaskFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 200, height: 150)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TaskFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filter = TaskFilter.allCases[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)

        cell.textLabel?.text = filter.rawValue

        cell.accessoryType = (filter == selectedFilter) ? .checkmark : .none
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = TaskFilter.allCases[indexPath.row]
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
}
