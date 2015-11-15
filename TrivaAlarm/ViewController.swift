//
//  ViewController.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 7/22/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData
//import AlarmTableViewCell.swift
class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,  NSFetchedResultsControllerDelegate {

    var alarms = [Alarms]()
    var onAlarms = [Alarms]()
    var offAlarms = [Alarms]()
     var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor(red: 49, green: 128, blue: 197, alpha: 1)

              fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch _ {
        }


        editButtonItem().tintColor = UIColor.whiteColor()
         navigationItem.leftBarButtonItem = editButtonItem()
        if let tableview = tableView{
            tableview.allowsSelectionDuringEditing = true
            tableview.allowsSelection = false
        }

    

    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


     override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

        UIApplication.sharedApplication().delegate as! AppDelegate
            onAlarmsNotification()


        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle


        if let tableView = tableView {
            tableView.reloadData()

        }

    }

  

    func save() {

        do {
            try managedObjectContext!.save()

        } catch let error1 as NSError {
            let alertController = UIAlertController(title: "Default Style", message: "Error has Occur. \(error1)", preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                // ...
            }
            alertController.addAction(cancelAction)

            let OKAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)                                //Present the AlertController
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)

        }

    }

    func getFetchedResultController() -> NSFetchedResultsController {
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchAlarms(), managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
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
        if let tableview = tableView{
        tableview.reloadData()
        }
    }


    override func  setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)

    }

   func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
        if(editingStyle == .Delete ) {
            // Find the LogItem object the user is trying to delete
            let deleteAlarms:Alarms = fetchedResultController.objectAtIndexPath(indexPath) as! Alarms
            deleteAlarms.on = false

            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(deleteAlarms)

            // Refresh the table view to indicate that it's deleted

            onAlarmsNotification()

            do {
                try managedObjectContext?.save()
            } catch _ {
            }
         
            save()
        }
    }
    func offAlarmsNotificaion() {
        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        let predicate = NSPredicate(format: "on == %@", "0")

        fetchRequest.predicate = predicate
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]!

        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Alarms] {
            offAlarms = fetchResults
        }

        for alarm in offAlarms {
            for notificaion in notifications{
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.LongStyle
                formatter.timeStyle = NSDateFormatterStyle.LongStyle
                let alarmDate = formatter.stringFromDate(alarm.time)
                if let notifDate = notificaion.userInfo?["AlarmDate"] as? String{
                    if alarmDate == notifDate{
                         UIApplication.sharedApplication().cancelLocalNotification(notificaion)

                    }
                }
            }
            
        }

    }
    //On alarms methods
    func onAlarmsNotification() ->Void{

        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        let predicate = NSPredicate(format: "on == %@", "1")

        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Alarms] {
            onAlarms = fetchResults
        }
        for alarm in onAlarms {


            let notification = UILocalNotification()

            notification.alertBody = "It Time, It Time to Wake Up and Be Great" // text that will be displayed in the notification
            notification.fireDate =  alarm.time // todo item due date (when notification will be fired)
            notification.soundName = alarm.alertSound
            notification.timeZone = NSCalendar.currentCalendar().timeZone
            notification.repeatInterval = NSCalendarUnit.Minute
            var userInfo:[String:String] = [String:String]()

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

            let notification2Date:NSDate = alarm.time.dateByAddingTimeInterval(30)
            notification2.alertBody = "It Time, It Time to Wake Up and Be Great" // text that will be displayed in the notification
            notification2.fireDate =  notification2Date // todo item due date (when notification will be fired)
            notification2.soundName = alarm.alertSound
            notification2.timeZone = NSCalendar.currentCalendar().timeZone
            notification2.repeatInterval = NSCalendarUnit.Minute

            notification2.userInfo = userInfo
            UIApplication.sharedApplication().scheduleLocalNotification(notification2)
        }
        
    }


    @IBAction func onAlarmClockSwitch(sender: UISwitch) {

        let senderTag = sender.tag as Int
        let indexPath = NSIndexPath(forRow: senderTag, inSection: 0)
       let alarmAtIndex:Alarms = fetchedResultController.objectAtIndexPath(indexPath) as! Alarms
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let nowComponents = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: now)
        let alarmComponents = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: alarmAtIndex.time)


        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .MediumStyle
        if sender.on {
           alarmAtIndex.on = true
            var alarmDate:NSDate


            if calendar.isDate(alarmAtIndex.time, inSameDayAsDate: now){
                if calendar.isDate(now, equalToDate: alarmAtIndex.time, toUnitGranularity: .Hour) {

                    if alarmComponents.minute <= nowComponents.minute{

                       alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!


                    }

                    else{
                        alarmDate = calendar.dateFromComponents(alarmComponents)!

                    }
                } else if alarmComponents.hour < nowComponents.hour{


                    alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!

                }else{
                    alarmDate = calendar.dateFromComponents(alarmComponents)!

                }
            }
            else{
                    if alarmComponents.hour == nowComponents.hour{
                        if alarmComponents.minute <= nowComponents.minute{


                            alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!


                        }else{
                            alarmComponents.day = nowComponents.day
                            alarmDate = calendar.dateFromComponents(alarmComponents)!


                        }
                    }else if alarmComponents.hour < nowComponents.hour{

                        alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!


                    }else{
                        alarmComponents.day = nowComponents.day
                        alarmDate = calendar.dateFromComponents(alarmComponents)!


                }
                    
                }

            alarmAtIndex.time = alarmDate
            save()
            onAlarmsNotification()





        }else{
            alarmAtIndex.on = false

           save()
            offAlarmsNotificaion()
        }

    }

    //tableView delegate methods

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:AlarmTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyCellID") as! AlarmTableViewCell
        let theAlarm = fetchedResultController.objectAtIndexPath(indexPath) as! Alarms

        cell.alarmNameLabel.text = theAlarm.name
        let alarmDate = theAlarm.valueForKey("time") as! NSDate


        cell.loadItem(alarmDate, isOn:theAlarm.on);
        cell.alarmSwitch.tag = indexPath.row
        cell.editingAccessoryType = UITableViewCellAccessoryType.DisclosureIndicator


        if theAlarm.on{


         let imageView = UIImageView(image: UIImage(named: "enabledAlarm_Bg"))
            cell.backgroundView = imageView

        }else{

            let imageView = UIImageView(image: UIImage(named: "disabledAlarm_Bg"))


            cell.backgroundView = imageView

        }

        return cell
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "oldAlarm") {
            let viewController:NewAlarmViewController = segue.destinationViewController as! NewAlarmViewController

            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)

            let theAlarm:Alarms = self.fetchedResultController.objectAtIndexPath(indexPath!) as! Alarms
             viewController.segueAlarm = theAlarm
         
        }
    }

}

extension NSCalendar {
    /// Returns the hour, minute, second, and nanoseconds of a given date.
    func getTimeFromDate(date: NSDate) -> (hour: Int, minute: Int, second: Int, nanosecond: Int) {
        var (hour, minute, second, nanosecond) = (0, 0, 0, 0)
        getHour(&hour, minute: &minute, second: &second, nanosecond: &nanosecond, fromDate: date)
        return (hour, minute, second, nanosecond)
    }

    /// Returns the era, year, month, and day of a given date.
  }

