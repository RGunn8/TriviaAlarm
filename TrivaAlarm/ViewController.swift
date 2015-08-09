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
class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    var alarms = [Alarms]()
    var onAlarms = [Alarms]()

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet var tableView: UITableView!
    @IBOutlet var clockLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)

        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let now = NSDate()
      
        

         navigationItem.leftBarButtonItem = editButtonItem()
        
        
        self.clockLabel?.text = formatter.stringFromDate(now)

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "questionSegue", name: "questionSegue", object: nil)

    }

     override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
        UIApplication.sharedApplication().cancelAllLocalNotifications()

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "questionSegue", name: "questionSegue", object: nil)

         if let moc = self.managedObjectContext {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
            onAlarmsNotification()

        //3
        var error: NSError?

        }

        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let now = NSDate()
        fetchLog()
        if let tableView = tableView {
            tableView.reloadData()
            println("relod")
        }


    }

    func questionSegue(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionVC") as! QuestionViewController
       self.presentViewController(vc, animated: true, completion: nil)

    }

    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        fetchRequest.returnsObjectsAsFaults = false

//        // Create a sort descriptor object that sorts on the "title"
//        // property of the Core Data object
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//
//        // Set the list of sort descriptors in the fetch request,
//        // so it includes the sort descriptor
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        // Create a new predicate that filters out any object that
//        // doesn't have a title of "Best Language" exactly.
//        let firstPredicate = NSPredicate(format: "title == %@", "Best Language")
//
//        // Search for only items using the substring "Worst"
//        let thPredicate = NSPredicate(format: "title contains %@", "Worst")
//
//        // Combine the two predicates above in to one compound predicate
//        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: [firstPredicate, thPredicate])
//
//        // Set the predicate on the fetch request
//        fetchRequest.predicate = predicate

        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Alarms] {

            alarms = fetchResults
        }
            }

    @IBAction func EditButtonPressed(sender: UIBarButtonItem) {
       // self.tableView.setEditing(true, animated: true)
    }

    override func  setEditing(editing: Bool, animated: Bool) {
            super.setEditing(editing, animated: animated)
            tableView.setEditing(editing, animated: animated)
      
    }
    func onAlarmsNotification() ->Void{

        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        let predicate = NSPredicate(format: "on == %@", "1")

        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Alarms] {
            onAlarms = fetchResults
        }
        print(onAlarms)


        for alarm in onAlarms {


            var notification = UILocalNotification()

             let notificationDate:NSDate = NSDate(timeInterval: 5, sinceDate: alarm.time)
            notification.alertBody = "It Time, It Time to Wake Up and Be Great" // text that will be displayed in the notification
            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
            notification.fireDate =  alarm.time // todo item due date (when notification will be fired)
            notification.soundName = alarm.alertSound// play default sound
            notification.timeZone = NSCalendar.currentCalendar().timeZone
            notification.repeatInterval = NSCalendarUnit.CalendarUnitMinute
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

//            println("This is the date \(alarmDate)")
            notification.userInfo = userInfo


            UIApplication.sharedApplication().scheduleLocalNotification(notification)


        }

    }

    func updateTime() ->Void {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let now = NSDate()
         self.clockLabel?.text = formatter.stringFromDate(now)

    }


   func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
        if(editingStyle == .Delete ) {
            // Find the LogItem object the user is trying to delete
            let deleteAlarms = alarms[indexPath.row]
            deleteAlarms.on = false

            // Delete it from the managedObjectContext
            managedObjectContext?.deleteObject(deleteAlarms)

            // Refresh the table view to indicate that it's deleted
            self.fetchLog()
            onAlarmsNotification()

            // Tell the table view to animate out that row
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.reloadData()
            //println("\(deleteAlarms.on)")
            save()
        }
    }

    

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    @IBAction func onAlarmClockSwitch(sender: UISwitch) {
        var alarmAtIndex:Alarms = alarms[sender.tag]
        let now = NSDate()
        if sender.on {
           alarmAtIndex.on = true
            if alarmAtIndex.time.compare(now) == NSComparisonResult.OrderedAscending{
                let calendar = NSCalendar.currentCalendar()
                let dayComponent = NSDateComponents()
                dayComponent.day = 1


                var alarmDate:NSDate = calendar.dateByAddingComponents(dayComponent, toDate: alarmAtIndex.time, options: NSCalendarOptions(0))!
//                let theNewDateString = formatter.stringFromDate(alarmDate)
//                let nowString = formatter.stringFromDate(now)
//
//                println("\(theNewDateString), and now is \(nowString) and this time is later " )
                alarmAtIndex.time = alarmDate

            }
            
            var error:NSError?
            save()
                onAlarmsNotification()


        }else{
            alarmAtIndex.on = false
            var error:NSError?
           save()
           onAlarmsNotification()

        }

    }
    func save() {
        var error:NSError?
        if managedObjectContext!.save(&error){
            println(error?.localizedDescription)
        }

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:AlarmTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyCellID") as! AlarmTableViewCell
        var alarm = alarms[indexPath.row]
        cell.backgroundColor = UIColor.clearColor()

        let alarmDate = alarm.valueForKey("time") as! NSDate
        //let alarmIsOn = alarm.valueForKey("on") as! Bool

        cell.loadItem(alarmDate, isOn:alarm.on);
        cell.alarmSwitch.tag = indexPath.row
        
        

        return cell
    }

}

