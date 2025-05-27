//
//  Task+CoreDataProperties.swift
//  TaskManager
//
//  Created by Santosh Singh on 21/05/25.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String
    @NSManaged public var createdOn: Date
    @NSManaged public var updatedOn: Date
    @NSManaged public var dueDate: Date
    @NSManaged public var isCompleted: Bool
    @NSManaged public var priority: Int16

}

extension Task : Identifiable {

}
