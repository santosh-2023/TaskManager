//
//  TaskTableViewCell.swift
//  TaskManager
//
//  Created by Santosh Singh on 22/05/25.
//

import UIKit

protocol TaskTableViewCellDelegate: AnyObject {
    func taskCellDidTapEdit(_ cell: TaskTableViewCell)
    func taskCellDidTapDetail(_ cell: TaskTableViewCell)
}

class TaskTableViewCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dueDateLabel = UILabel()
    private let container = UIStackView()
    private let cardView = UIView()

    weak var delegate: TaskTableViewCellDelegate?

    private let statusIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemOrange // Default to incomplete
        view.layer.masksToBounds = true
        return view
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil.circle"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let detailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        let inset = CGFloat(5)
//        let safeBounds = bounds.inset(by: UIEdgeInsets(top: inset, left: 10, bottom: inset, right: 10))
//        contentView.frame = safeBounds
//    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card view
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Labels
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray

        dueDateLabel.font = .systemFont(ofSize: 12)
        dueDateLabel.textColor = .secondaryLabel

        // Stack view for labels
        container.axis = .vertical
        container.spacing = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(descriptionLabel)
        container.addArrangedSubview(dueDateLabel)

        // Buttons (not in any stack)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        detailButton.setImage(UIImage(systemName: "info.circle"), for: .normal)

        // Status indicator
        statusIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        statusIndicatorView.backgroundColor = .systemOrange

        // Add to hierarchy
        cardView.addSubview(container)
        cardView.addSubview(editButton)
        cardView.addSubview(detailButton)
        cardView.addSubview(statusIndicatorView)
        contentView.addSubview(cardView)

        // Actions
        editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        detailButton.addTarget(self, action: #selector(detailButtonAction), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Card view padding
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            // Status indicator (left)
            statusIndicatorView.topAnchor.constraint(equalTo: cardView.topAnchor),
            statusIndicatorView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            statusIndicatorView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            statusIndicatorView.widthAnchor.constraint(equalToConstant: 10),

            // Edit button (top right)
            editButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            editButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            editButton.widthAnchor.constraint(equalToConstant: 24),
            editButton.heightAnchor.constraint(equalToConstant: 24),

            // Detail button (center right)
            detailButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            detailButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            detailButton.widthAnchor.constraint(equalToConstant: 24),
            detailButton.heightAnchor.constraint(equalToConstant: 24),

            // Label container
            container.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            container.leadingAnchor.constraint(equalTo: statusIndicatorView.trailingAnchor, constant: 8),
            container.trailingAnchor.constraint(equalTo: detailButton.leadingAnchor, constant: -8),
            container.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -10)
        ])
    }


    func configure(with task: Task) {
        titleLabel.text = task.title
        descriptionLabel.text = !task.taskDescription.isEmpty ? task.taskDescription : "No Description"
        dueDateLabel.text = "Due: \(task.dueDate.formatted(date: .abbreviated, time: .shortened))"

        switch task.priority {
            case 0:
                cardView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            case 1:
                cardView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
            case 2:
                cardView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            default:
                cardView.backgroundColor = UIColor.systemGray5
        }

        statusIndicatorView.backgroundColor = task.isCompleted ? .systemGreen : .systemOrange
    }

    @objc func editButtonAction(_ sender: UIButton) {
        delegate?.taskCellDidTapEdit(self)
    }

    @objc func detailButtonAction(_ sender: UIButton) {
        delegate?.taskCellDidTapDetail(self)
    }
}



