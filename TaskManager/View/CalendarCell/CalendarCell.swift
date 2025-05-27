//
//  CalendarCell.swift
//  TaskManager
//
//  Created by Santosh Singh on 22/05/25.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTACDayCell {
    let dateLabel = UILabel()
    let dotView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dotView.translatesAutoresizingMaskIntoConstraints = false

        dotView.backgroundColor = .systemBlue
        dotView.layer.cornerRadius = 3
        dotView.isHidden = true

        contentView.addSubview(dateLabel)
        contentView.addSubview(dotView)

        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            dotView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 2),
            dotView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 6),
            dotView.heightAnchor.constraint(equalToConstant: 6)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
