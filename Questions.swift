//
//  Questions.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 7/31/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import Foundation
import CoreData

class Questions: NSManagedObject {

    @NSManaged var correctAnswer: String
    @NSManaged var isCorrect: NSNumber
    @NSManaged var optionA: String
    @NSManaged var optionB: String
    @NSManaged var optionC: String
    @NSManaged var optionD: String
    @NSManaged var question: String
    @NSManaged var type: String

}
