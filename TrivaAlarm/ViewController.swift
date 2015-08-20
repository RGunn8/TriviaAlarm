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
     var fetchedResultController: NSFetchedResultsController = NSFetchedResultsController()

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
              fetchedResultController = getFetchedResultController()
        fetchedResultController.delegate = self
        fetchedResultController.performFetch(nil)

         navigationItem.leftBarButtonItem = editButtonItem()
        if let tableview = tableView{
            tableview.allowsSelectionDuringEditing = true
            tableview.allowsSelection = false
        }

    }



     override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
        UIApplication.sharedApplication().cancelAllLocalNotifications()


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

        if let tableView = tableView {
            tableView.reloadData()

        }


    }

    func save() {
        var error:NSError?
        if managedObjectContext!.save(&error){
            println(error?.localizedDescription)
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

            managedObjectContext?.save(nil)
            //println("\(deleteAlarms.on)")
            save()
        }
    }

    //On alarms methods
    func onAlarmsNotification() ->Void{

        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        let predicate = NSPredicate(format: "on == %@", "1")

        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Alarms] {
            onAlarms = fetchResults
        }
        for alarm in onAlarms {


            var notification = UILocalNotification()

            notification.alertBody = "It Time, It Time to Wake Up and Be Great" // text that will be displayed in the notification
            notification.fireDate =  alarm.time // todo item due date (when notification will be fired)
            notification.soundName = alarm.alertSound
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

            notification.userInfo = userInfo


            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            var notification2 = UILocalNotification()

            let notification2Date:NSDate = alarm.time.dateByAddingTimeInterval(30)
            notification2.alertBody = "It Time, It Time to Wake Up and Be Great" // text that will be displayed in the notification
            notification2.fireDate =  notification2Date // todo item due date (when notification will be fired)
            notification2.soundName = alarm.alertSound
            notification2.timeZone = NSCalendar.currentCalendar().timeZone
            notification2.repeatInterval = NSCalendarUnit.CalendarUnitMinute

            notification2.userInfo = userInfo
            UIApplication.sharedApplication().scheduleLocalNotification(notification2)
        }
        
    }


    @IBAction func onAlarmClockSwitch(sender: UISwitch) {

        let senderTag = sender.tag as Int
        let indexPath = NSIndexPath(forRow: senderTag, inSection: 0)
       var alarmAtIndex:Alarms = fetchedResultController.objectAtIndexPath(indexPath) as! Alarms
        let now = NSDate()
        if sender.on {
           alarmAtIndex.on = true
            if alarmAtIndex.time.compare(now) == NSComparisonResult.OrderedAscending{
                let calendar = NSCalendar.currentCalendar()
                let dayComponent = NSDateComponents()
                dayComponent.day = 1


                var alarmDate:NSDate = calendar.dateByAddingComponents(dayComponent, toDate: alarmAtIndex.time, options: NSCalendarOptions(0))!

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

    //tableView delegate methods

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInSection!
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:AlarmTableViewCell = tableView.dequeueReusableCellWithIdentifier("MyCellID") as! AlarmTableViewCell
        var theAlarm = fetchedResultController.objectAtIndexPath(indexPath) as! Alarms
        cell.backgroundColor = UIColor.clearColor()
        cell.alarmNameLabel.text = theAlarm.name
        let alarmDate = theAlarm.valueForKey("time") as! NSDate
        //let alarmIsOn = alarm.valueForKey("on") as! Bool

        cell.loadItem(alarmDate, isOn:theAlarm.on);
        cell.alarmSwitch.tag = indexPath.row
        cell.editingAccessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        if theAlarm.on{
           cell.backgroundColor = UIColor.redColor()

        }else{
             cell.backgroundColor = UIColor.blueColor()
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



