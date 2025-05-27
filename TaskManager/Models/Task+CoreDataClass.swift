//
//  Task+CoreDataClass.swift
//  TaskManager
//
//  Created by Santosh Singh on 21/05/25.
//
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {

}

extension Task {
    static func fetchAll() -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        return (try? CoreDataManager.shared.context.fetch(request)) ?? []
    }

    static func create(title: String, desc: String, dueDate: Date, priority: Int16) -> Task {
        let task = Task(context: CoreDataManager.shared.context)
        task.id = UUID()
        task.title = title
        task.taskDescription = desc
        task.dueDate = dueDate
        task.createdOn = Date()
        task.updatedOn = Date()
        task.priority = priority
        task.isCompleted = false
        CoreDataManager.shared.save()

        return task
    }

    func update(title: String, desc: String, dueDate: Date, priority: Int16) -> Task {
        self.title = title
        self.taskDescription = desc
        self.dueDate = dueDate
        self.updatedOn = Date()
        self.priority = priority
        CoreDataManager.shared.save()
        return self
    }

    func delete() {
        CoreDataManager.shared.context.delete(self)
        CoreDataManager.shared.save()
    }
}

