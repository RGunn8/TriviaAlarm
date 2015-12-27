//
//  RemindersViewController.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 12/26/15.
//  Copyright © 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
enum ReminderAbbreviation {
    case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday

    func dayAbbreviation(reminderAbbreviation: ReminderAbbreviation) -> String {
        switch reminderAbbreviation {
        case .Sunday:
            return "Sun"
        case .Monday:
            return "Mon"
        case .Tuesday:
            return "Tues"
        case .Wednesday:
            return "Wed"
        case .Thursday:
            return "Thur"
        case .Friday:
            return "Fri"
        case .Saturday:
            return "Sat"

        }
    }

}

struct ReminderStruct {
    var name = ""
    var isSelected = false
    var abbreviation: ReminderAbbreviation?

}
class RemindersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var remindersArray = [ReminderStruct(name: "Every Sunday", isSelected: false, abbreviation: .Sunday), ReminderStruct(name: "Every Monday", isSelected: false, abbreviation: .Monday), ReminderStruct(name: "Every Tuesday", isSelected: false, abbreviation: .Tuesday),
        ReminderStruct(name: "Every Wednesday", isSelected: false, abbreviation: .Wednesday),
        ReminderStruct(name: "Every Thursday", isSelected: false, abbreviation: .Thursday),
        ReminderStruct(name: "Every Friday", isSelected: false, abbreviation: .Friday),
        ReminderStruct(name: "Every Saturday", isSelected: false, abbreviation: .Saturday)]
    var reminderSelectedArray = [ReminderStruct]()
    var delegate: RemindersPickerDelegate?
    @IBOutlet var tableView: UITableView!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

         delegate?.didSelectedReminder(reminderSelectedArray)

        // Do any additional setup after loading the view.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCellID")! as UITableViewCell
        let reminderNameAtIndex = remindersArray[indexPath.row]
        cell.textLabel?.text = reminderNameAtIndex.name

        return cell
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        var reminderNameAtIndex = remindersArray[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        if cell?.accessoryType == UITableViewCellAccessoryType.Checkmark {

            cell!.accessoryType = UITableViewCellAccessoryType.None
             reminderNameAtIndex.isSelected = false
              remindersArray[indexPath.row] = reminderNameAtIndex
            let reminderFiltered = remindersArray.filter { $0.isSelected != false}
            delegate?.didSelectedReminder(reminderFiltered)

        } else {
             reminderNameAtIndex.isSelected = true

            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            remindersArray[indexPath.row] = reminderNameAtIndex
            let reminderFiltered = remindersArray.filter { $0.isSelected != false}
            delegate?.didSelectedReminder(reminderFiltered)
        }
        tableView.reloadData()
    }
    
}

protocol RemindersPickerDelegate {

    func didSelectedReminder(reminderArray: Array<ReminderStruct>)
}
