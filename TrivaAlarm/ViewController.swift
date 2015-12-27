//
//  ViewController.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 7/22/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    var alarms = [Alarms]()
    var onAlarms = [Alarms]()
    var offAlarms = [Alarms]()
    var remindersAlarms = [Alarms]()
     var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()

    var coreDataStack: CoreDataStack!

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor(red: 49, green: 128, blue: 197, alpha: 1)

              fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {

            let alertViewControler = UIAlertController(title: "Error has Occured", message: "Cannot fetch alarms try again has occued \(error)", preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                // ...
            }
            alertViewControler.addAction(cancelAction)

            let oKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertViewControler.addAction(oKAction)

            self.presentViewController(alertViewControler, animated: true, completion: nil)
        }

        editButtonItem().tintColor = UIColor.whiteColor()
         navigationItem.leftBarButtonItem = editButtonItem()
        if let tableview = tableView {
            tableview.allowsSelectionDuringEditing = true
            tableview.allowsSelection = false
        }

    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

     override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

        onAlarmsNotification()

        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle

        if let tableView = tableView {
            tableView.reloadData()
        }

    }

    // On add button tapped pass the coredate stack object to NewAlarmVC
    @IBAction func onAddButtonTapped(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewControllerWithIdentifier("newAlarmVC") as? NewAlarmViewController {
            vc.theCoreDataStack = coreDataStack
            navigationController?.pushViewController(vc, animated: true)
        }

    }

    // Fetch Results Controllers methods
    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchAlarms(), managedObjectContext: coreDataStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }

    func fetchAlarms() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        fetchRequest.returnsObjectsAsFaults = false
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if let tableview = tableView {
        tableview.reloadData()
        }
    }

    override func  setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)

    }

   func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Find the LogItem object the user is trying to delete
            if let deleteAlarm = fetchedResultController.objectAtIndexPath(indexPath) as? Alarms {
                deleteAlarm.on = false
                // Delete it from the managedObjectContext
                coreDataStack.managedObjectContext.deleteObject(deleteAlarm)

                // Refresh the table view to indicate that it's deleted
                onAlarmsNotification()
                coreDataStack.saveMainContext()
            }
        }
    }

    // When the users switchs the alarm add the alarm to the offAlarm array and turn off the notificaion
    func offAlarmsNotificaion() {
        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        let predicate = NSPredicate(format: "on == %@", "0")

        fetchRequest.predicate = predicate
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]!

        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Alarms] {
            offAlarms = fetchResults
        }

        for alarm in offAlarms {
            for notificaion in notifications {
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.LongStyle
                formatter.timeStyle = NSDateFormatterStyle.LongStyle
                let alarmDate = formatter.stringFromDate(alarm.time)
                if let notifDate = notificaion.userInfo?["AlarmDate"] as? String {
                    if alarmDate == notifDate {
                         UIApplication.sharedApplication().cancelLocalNotification(notificaion)

                    }
                }
            }
        }

    }

    // On alarms methods
    func onAlarmsNotification() -> Void {

        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        let predicate = NSPredicate(format: "on == %@", "1")

        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Alarms] {
            onAlarms = fetchResults.filter({$0.hasReminder == false})
            remindersAlarms = fetchResults.filter({$0.hasReminder == true})

        }
        for alarm in onAlarms {
                setNotfiicaitonsForOnAlarms(alarm)

        }

        for alarm in remindersAlarms {
             if alarm.reminder?.rangeOfString("Sun") != nil {
                setReminderNotification(alarm, day: "Sunday")

            }

             if alarm.reminder?.rangeOfString("Mon") != nil {
                 setReminderNotification(alarm, day: "Monday")
            }
            if alarm.reminder?.rangeOfString("Tues") != nil {
                 setReminderNotification(alarm, day: "Tuesday")
            }
            if alarm.reminder?.rangeOfString("Wed") != nil {
                 setReminderNotification(alarm, day: "Wednesday")
            }
            if alarm.reminder?.rangeOfString("Thur") != nil {
                 setReminderNotification(alarm, day: "Thursday")
            }
            if alarm.reminder?.rangeOfString("Fri") != nil {
                 setReminderNotification(alarm, day: "Friday")
            }

            if alarm.reminder?.rangeOfString("Sat") != nil {
                 setReminderNotification(alarm, day: "Saturday")

            }
        }
    }

    func setNotfiicaitonsForOnAlarms (alarm: Alarms) {
        let notification = UILocalNotification()

        notification.alertBody = "It Time, It Time to Wake Up and Be Great" // text that will be displayed in the notification
        notification.fireDate =  alarm.time
        notification.soundName = alarm.alertSound
        notification.timeZone = NSCalendar.currentCalendar().timeZone
        notification.repeatInterval = NSCalendarUnit.Minute
        var userInfo: [String: String] = [String: String]()

        let numOfQuestion = "\(alarm.numOfQuestionsToEnd)" as String
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.LongStyle
        let alarmDate = formatter.stringFromDate(alarm.time)

        userInfo["NumberOfQuestion"] = numOfQuestion ?? "1"

        userInfo["TypeOfQuestion"] = alarm.questionType ?? "Random"

        userInfo["AlarmDate"] = alarmDate ?? "nil"

        userInfo["AlarmSound"] = alarm.alertSound ?? "LoudAlarm.wav"

        notification.userInfo = userInfo

        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        let notification2 = UILocalNotification()

        let notification2Date: NSDate = alarm.time.dateByAddingTimeInterval(30)
        notification2.alertBody = "It Time, It Time to Wake Up and Be Great" // text that will be displayed in the notification
        notification2.fireDate =  notification2Date
        notification2.soundName = alarm.alertSound
        notification2.timeZone = NSCalendar.currentCalendar().timeZone
        notification2.repeatInterval = NSCalendarUnit.Minute

        notification2.userInfo = userInfo
        UIApplication.sharedApplication().scheduleLocalNotification(notification2)
    }

    func setReminderNotification(alarm: Alarms, day: String) {
        let calendar = NSCalendar.currentCalendar()
        let alarmDateComponents = calendar.components([.Hour,.Minute], fromDate: alarm.time)
        let nextDayComponets = calendar.components([.Day, .Year], fromDate: get(.Next, day))
        let nextDayReminderComponents = NSDateComponents()
       nextDayReminderComponents.hour = alarmDateComponents.hour
        nextDayReminderComponents.minute = alarmDateComponents.minute
        nextDayReminderComponents.day = nextDayComponets.day
        nextDayReminderComponents.year = nextDayComponets.year
        let nextDayRepeatNotification = UILocalNotification()
        nextDayRepeatNotification.fireDate = calendar.dateFromComponents(nextDayReminderComponents)
        nextDayRepeatNotification.repeatInterval = NSCalendarUnit.WeekOfMonth
        nextDayRepeatNotification.soundName = alarm.alertSound
        nextDayRepeatNotification.alertBody = "It Time, It Time to Wake Up and Be Great"

        var userInfo: [String: String] = [String: String]()

        let numOfQuestion = "\(alarm.numOfQuestionsToEnd)" as String
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.LongStyle
        let alarmDate = formatter.stringFromDate(alarm.time)

        userInfo["NumberOfQuestion"] = numOfQuestion ?? "1"

        userInfo["TypeOfQuestion"] = alarm.questionType ?? "Random"

        userInfo["AlarmDate"] = alarmDate ?? "nil"

        userInfo["AlarmSound"] = alarm.alertSound ?? "LoudAlarm.wav"

        nextDayRepeatNotification.userInfo = userInfo
        UIApplication.sharedApplication().scheduleLocalNotification(nextDayRepeatNotification)
        // Create another notfiication that fire off 30 seconds later

        let alarmDateCompoents2 = calendar.components([.Hour, .Minute], fromDate: alarm.time.dateByAddingTimeInterval(30))

        let nextDayReminderComponents2 = NSDateComponents()
        nextDayReminderComponents2.hour = alarmDateCompoents2.hour
        nextDayReminderComponents2.minute = alarmDateCompoents2.minute
        nextDayReminderComponents2.day = nextDayComponets.day
        nextDayReminderComponents2.year = nextDayComponets.year
        let nextDayRepeatNotification2 = UILocalNotification()
        nextDayRepeatNotification2.fireDate = calendar.dateFromComponents(nextDayReminderComponents2)
        nextDayRepeatNotification2.repeatInterval = NSCalendarUnit.WeekOfMonth
        nextDayRepeatNotification2.soundName = alarm.alertSound
        nextDayRepeatNotification2.alertBody = "It Time, It Time to Wake Up and Be Great"
        nextDayRepeatNotification2.userInfo = userInfo
         UIApplication.sharedApplication().scheduleLocalNotification(nextDayRepeatNotification2)

    }

    @IBAction func onAlarmClockSwitch(sender: UISwitch) {

        let senderTag = sender.tag as Int
        let indexPath = NSIndexPath(forRow: senderTag, inSection: 0)
        guard let alarmAtIndex = fetchedResultController.objectAtIndexPath(indexPath) as? Alarms else {
            return
        }
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let nowComponents = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: now)
        let alarmComponents = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: alarmAtIndex.time)

        // Set the alarm date and add it to the alarm and save it
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .MediumStyle
        if sender.on {
           alarmAtIndex.on = true
            var alarmDate: NSDate

            if calendar.isDate(alarmAtIndex.time, inSameDayAsDate: now) {
                if calendar.isDate(now, equalToDate: alarmAtIndex.time, toUnitGranularity: .Hour) {

                    if alarmComponents.minute <= nowComponents.minute {

                       alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!
                    } else {
                        alarmDate = calendar.dateFromComponents(alarmComponents)!

                    }
                } else if alarmComponents.hour < nowComponents.hour {
                    alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!

                }else {
                    alarmDate = calendar.dateFromComponents(alarmComponents)!
                }
            } else {
                    if alarmComponents.hour == nowComponents.hour {
                        if alarmComponents.minute <= nowComponents.minute {
                            alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!
                        }else {
                            alarmComponents.day = nowComponents.day
                            alarmDate = calendar.dateFromComponents(alarmComponents)!
                        }
                    }else if alarmComponents.hour < nowComponents.hour {

                        alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!


                    }else {
                        alarmComponents.day = nowComponents.day
                        alarmDate = calendar.dateFromComponents(alarmComponents)!
                   }
                }

            alarmAtIndex.time = alarmDate
            coreDataStack.saveMainContext()
            onAlarmsNotification()


        } else {
            alarmAtIndex.on = false

           coreDataStack.saveMainContext()
            offAlarmsNotificaion()
        }
    }

    // tableView delegate methods

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        guard let cell: AlarmTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyCellID") as? AlarmTableViewCell else {
            return UITableViewCell()
        }
        guard let alarmAtIndex = fetchedResultController.objectAtIndexPath(indexPath) as? Alarms else {
            return cell
        }
        if let alarmReminder = alarmAtIndex.reminder {
            if alarmReminder == " Sun Mon Tues Wed Thur Fri Sat"{
                 cell.alarmNameLabel.text = alarmAtIndex.name + "," + "Every Day"
            } else if alarmReminder == " Mon Tues Wed Thur Fri" {
                 cell.alarmNameLabel.text = alarmAtIndex.name + "," + " Week Days"
            } else if alarmReminder == "None"{
                cell.alarmNameLabel.text = alarmAtIndex.name
            } else {
                 cell.alarmNameLabel.text = alarmAtIndex.name + "," + alarmReminder
            }

        }else {
            cell.alarmNameLabel.text = alarmAtIndex.name
        }

        print(cell.alarmNameLabel.text)
        guard let alarmDate = alarmAtIndex.valueForKey("time") as? NSDate else {
            return cell
        }

        cell.loadItem(alarmDate, isOn: alarmAtIndex.on)
        cell.alarmSwitch.tag = indexPath.row
        cell.editingAccessoryType = UITableViewCellAccessoryType.DisclosureIndicator


        if alarmAtIndex.on {

         let imageView = UIImageView(image: UIImage(named: "enabledAlarm_Bg"))
            cell.backgroundView = imageView

        }else {

            let imageView = UIImageView(image: UIImage(named: "disabledAlarm_Bg"))
            cell.backgroundView = imageView
        }

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "oldAlarm" {
            guard let newAlarmVc = segue.destinationViewController as? NewAlarmViewController else {
                return
            }
            guard let cell = sender as? UITableViewCell else{
                return
            }

            guard let indexPath = tableView.indexPathForCell(cell) else {
                return
            }

            guard let alarmAtIndex = fetchedResultController.objectAtIndexPath(indexPath) as? Alarms else{
                return
            }
            newAlarmVc.segueAlarm = alarmAtIndex
            newAlarmVc.theCoreDataStack = coreDataStack
        }

    }

    func getWeekDaysInEnglish() -> [String] {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }

    enum SearchDirection {
        case Next
        case Previous

        var calendarOptions: NSCalendarOptions {
            switch self {
            case .Next:
                return .MatchNextTime
            case .Previous:
                return [.SearchBackwards, .MatchNextTime]
            }
        }
    }

    func get(direction: SearchDirection, _ dayName: String, considerToday consider: Bool = false) -> NSDate {
        let weekdaysName = getWeekDaysInEnglish()
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")

        let nextWeekDayIndex = weekdaysName.indexOf(dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6

        let today = NSDate()

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!

        if consider && calendar.component(.Weekday, fromDate: today) == nextWeekDayIndex {
            return today
        }

        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        let date = calendar.nextDateAfterDate(today, matchingComponents: nextDateComponent, options: direction.calendarOptions)
        return date!
    }
    
}

extension ViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No Alarms")
    }

    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Add an alarm by pressing the plus button in the right head corner ")
    }
    
}

