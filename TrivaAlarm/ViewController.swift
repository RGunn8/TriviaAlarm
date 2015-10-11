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
        //let swift color =

//        tableView.backgroundView?.backgroundColor = UIColor(red: 0, green: (128/255), blue: (255/255), alpha: 1)
//        tableView.backgroundColor =  UIColor(red: 0, green: (128/255), blue: (255/255), alpha: 1)


//        self.nav.barStyle = UIBarStyle.Black
//        self.navigationBar.tintColor = UIColor.whiteColor()
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
       
         //if let moc = self.managedObjectContext {
       //let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
            onAlarmsNotification()

        //3
        //var error: NSError?

        //}

        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle


        if let tableView = tableView {
            tableView.reloadData()

        }


    }

    func save() {
        var error:NSError?
        do {
            try managedObjectContext!.save()
            if error != nil{
                print("\(error)")
            }
        } catch let error1 as NSError {
            error = error1
        }

    }
    //NSFetchController Methods

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

    func questionSegue(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionVC") as! QuestionViewController
       self.presentViewController(vc, animated: true, completion: nil)

    }




    //Editing TableView Methods

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
            //println("\(deleteAlarms.on)")
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
                        print("\(notificaion)")
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


//         var notifications = UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]!

        //println("\(notifications)")
        let senderTag = sender.tag as Int
        let indexPath = NSIndexPath(forRow: senderTag, inSection: 0)
       let alarmAtIndex:Alarms = fetchedResultController.objectAtIndexPath(indexPath) as! Alarms
        let now = NSDate()
        if sender.on {
           alarmAtIndex.on = true
            if alarmAtIndex.time.compare(now) == NSComparisonResult.OrderedAscending{
                let calendar = NSCalendar.currentCalendar()


//                let components = calendar.components([.Month, .Year, .Hour, .Minute, .Second, .Nanosecond], fromDate: now)

                let year = calendar.component(.Year, fromDate: now)
                let month = calendar.component(.Month, fromDate: now)
                var day = calendar.component(.Day, fromDate: now)
                let hour = calendar.component(.Hour, fromDate: alarmAtIndex.time)
                let mins = calendar.component(.Minute, fromDate: alarmAtIndex.time)
                let nowHour = calendar.component(.Hour, fromDate: now)
                let nowmin = calendar.component(.Minute, fromDate: now)

                if nowHour > hour {
                    day++

                }else if nowHour == hour{
                    if nowmin > mins{
                        day++
                    }

                }
//                let second = 0
                let newAlarmDateComponents = NSDateComponents()
                newAlarmDateComponents.year = year
                newAlarmDateComponents.month = month
                newAlarmDateComponents.day = day
                newAlarmDateComponents.hour = hour
                newAlarmDateComponents.minute = mins
                newAlarmDateComponents.second = 0


                let alarmDate:NSDate = calendar.dateFromComponents(newAlarmDateComponents)!


                alarmAtIndex.time = alarmDate

                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.LongStyle
                formatter.timeStyle = .MediumStyle
               let alarmStirng = formatter.stringFromDate(alarmDate)
//                let datestring = formatter.stringFromDate(alarmAtIndex.time)
//                let nowstring = formatter.stringFromDate(now)
//                let theAalrm = calendar.getTimeFromDate(alarmDate)
                print("\(alarmStirng)");
                save()
                onAlarmsNotification()

            }



        }else{
            alarmAtIndex.on = false
//            var error:NSError?
           save()
           //onAlarmsNotification()
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
//        cell.backgroundColor = UIColor.redColor()
        cell.alarmNameLabel.text = theAlarm.name
        let alarmDate = theAlarm.valueForKey("time") as! NSDate
        //let alarmIsOn = alarm.valueForKey("on") as! Bool

        cell.loadItem(alarmDate, isOn:theAlarm.on);
        cell.alarmSwitch.tag = indexPath.row
        cell.editingAccessoryType = UITableViewCellAccessoryType.DisclosureIndicator


        if theAlarm.on{
           //cell.backgroundColor = UIColor.redColor()

         let imageView = UIImageView(image: UIImage(named: "enabledAlarm_Bg"))
            cell.backgroundView = imageView

        }else{
             //cell.backgroundColor = UIColor(red: 49, green: 128, blue: 197, alpha: 1)
            let imageView = UIImageView(image: UIImage(named: "disabledAlarm_Bg"))
            //cell.backgroundView = UIView()
            //cell.backgroundView = imageView

            cell.backgroundView = imageView

        }

        return cell
    }
    //Segue to NewAlarmVC

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

