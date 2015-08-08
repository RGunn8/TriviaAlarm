//
//  Alarms.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 7/25/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import Foundation
import CoreData

class Alarms: NSManagedObject {

    @NSManaged var alertSound: String
    @NSManaged var name: String
    @NSManaged var numOfQuestionsToEnd: NSNumber
    @NSManaged var on: Bool
    @NSManaged var questionType: String
    @NSManaged var snooze: NSNumber
    @NSManaged var time: NSDate

}
