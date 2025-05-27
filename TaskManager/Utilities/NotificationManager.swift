//
//  NotificationManager.swift
//  TaskManager
//
//  Created by Santosh Singh on 22/05/25.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotification(for event: Task) {
        guard let id = event.id else { return }

        let content = UNMutableNotificationContent()
        content.title = event.title
        content.body = event.taskDescription
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .minute, value: -15, to: event.dueDate)
        guard let triggerDate = triggerDate else { return }

        if triggerDate < Date() {
            return // Don't schedule past events
        }

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    func updateNotification(for event: Task) {
        deleteNotification(for: event)
        scheduleNotification(for: event)
    }

    func deleteNotification(for event: Task) {
        guard let id = event.id else { return }
        center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }

    func rescheduleAll(from events: [Task]) {
        center.getPendingNotificationRequests { requests in
            let now = Date()
            // Filter task IDs for tasks that have already passed, need to remove
            let pastTaskIDs = events
                .filter { $0.dueDate < now }
                .compactMap { $0.id?.uuidString }

            // Remove only past task notifications
            self.center.removePendingNotificationRequests(withIdentifiers: pastTaskIDs)
        }
    }
}
