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
        performFetch()

        fetchedResultController.delegate = self
        editButtonItem().tintColor = UIColor.whiteColor()
         navigationItem.leftBarButtonItem = editButtonItem()
        if let tableview = tableView {
            tableview.allowsSelectionDuringEditing = true
            tableview.allowsSelection = false
        }

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
        if let tableview = tableView{
            tableview.reloadData()
        }
    }

    func performFetch(){

        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {

            let alertViewControler = UIAlertController(title: "Error has Occured", message: "Cannot fetch alarms try again has occued \(error)", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

            alertViewControler.addAction(cancelAction)
            let okAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)

            alertViewControler.addAction(okAction)

            self.presentViewController(alertViewControler, animated: true, completion: nil)
        }
        
        
    }


    // When the users switchs the alarm add the alarm to the offAlarm array and turn off the notificaion
    func offAlarmsNotificaion() {
        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        let predicate = NSPredicate(format: "on == %@", "0")

        fetchRequest.predicate = predicate
        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Alarms] {
            offAlarms = fetchResults
        }

        for alarm in offAlarms {
            alarm.turnOffAlarmNotification()

            }

    }

    // On alarms methods
    func onAlarmsNotification() -> Void {

        let fetchRequest = NSFetchRequest(entityName: "Alarms")
        let predicate = NSPredicate(format: "on == %@", "1")

        // Set the predicate on the fetch request
        fetchRequest.predicate = predicate

        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Alarms] {
            onAlarms = fetchResults

        }
        for alarm in onAlarms {
            alarm.setNotfiicaitonsForOnAlarms()
            alarm.secondNotificationForAlarms()

        }
    }


    @IBAction func onAlarmClockSwitch(sender: UISwitch) {

        let senderTag = sender.tag as Int
        let indexPath = NSIndexPath(forRow: senderTag, inSection: 0)
        guard let alarmAtIndex = fetchedResultController.objectAtIndexPath(indexPath) as? Alarms else {
            return
        }

           if sender.on {
            alarmAtIndex.time = alarmAtIndex.setAlarmDate()
             alarmAtIndex.on = true
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

        cell.alarmNameLabel.text = alarmAtIndex.name

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

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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

