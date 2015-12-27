//
//  Alarms+CoreDataProperties.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 12/26/15.
//  Copyright © 2015 Ryan  Gunn. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Alarms {

    @NSManaged var alertSound: String
    @NSManaged var name: String
    @NSManaged var numOfQuestionsToEnd: NSNumber
    @NSManaged var on: Bool
    @NSManaged var questionType: String
    @NSManaged var time: NSDate
    @NSManaged var reminder: String?
    @NSManaged var hasReminder: Bool

}
