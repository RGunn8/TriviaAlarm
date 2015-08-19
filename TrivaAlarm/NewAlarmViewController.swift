//
//  NewAlarmViewController.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 7/22/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData

class NewAlarmViewController: ViewController, UITextFieldDelegate {


    @IBOutlet var alarmNameTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var numberOfQuestionLabel: UILabel!

    @IBOutlet var addQuestionButton: UIButton!
    @IBOutlet var subtractQuesitonButton: UIButton!

    @IBOutlet var questionTypeSegmentedControl: UISegmentedControl!
    var numberOfQuestions = 1
    var typeOfQuestion = "Random"
    var theAlarmSound = "LoudAlarm.wav"
    var segueAlarm:Alarms? = nil

    let theManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    @IBOutlet weak var cancel: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
               subtractQuesitonButton.hidden = true
        self.navigationItem.leftBarButtonItem = cancel

        alarmNameTextField.delegate = self

            if let segueAlarm = segueAlarm {
            numberOfQuestions = segueAlarm.numOfQuestionsToEnd as Int
            typeOfQuestion = segueAlarm.questionType
            alarmNameTextField.text = segueAlarm.name
            theAlarmSound = segueAlarm.alertSound
            datePicker.date = segueAlarm.time
             numberOfQuestionLabel.text? = String(numberOfQuestions)
        }
    }

    override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
        if numberOfQuestions == 1 {
            subtractQuesitonButton.hidden = true
        }else{
            subtractQuesitonButton.hidden = false
        }

        if numberOfQuestions == 5{
            addQuestionButton.hidden = true
        }else{
            addQuestionButton.hidden = false
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    func dismissViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewController()
    }

    @IBAction func saveButton(sender: UIBarButtonItem) {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()

        let components = calendar.components(.CalendarUnitYear | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitMonth, fromDate: datePicker.date)

        components.second = 0
        let zeroSecondDate:NSDate = calendar.dateFromComponents(components)!
        var alarmDate:NSDate
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .MediumStyle

        if datePicker.date.compare(now) == NSComparisonResult.OrderedAscending{

            let dayComponent = NSDateComponents()
            dayComponent.day = 1
            alarmDate = calendar.dateByAddingComponents(dayComponent, toDate: zeroSecondDate, options: NSCalendarOptions(0))!
            let theNewDateString = formatter.stringFromDate(alarmDate)
            let nowString = formatter.stringFromDate(now)
            println("\(nowString)")

        }else{
            alarmDate = zeroSecondDate
        }

        let dateString = formatter.stringFromDate(datePicker.date)
        let newDateString = formatter.stringFromDate(zeroSecondDate)

        if segueAlarm != nil{
            editAlarm(alarmDate)
        }else{
            createAlarm(alarmDate)
        }
        navigationController?.popViewControllerAnimated(true)

    }

        func editAlarm(alarmDate:NSDate){

        segueAlarm?.setValue(alarmNameTextField.text, forKey: "name")
        segueAlarm?.setValue(alarmDate, forKey: "time")
        segueAlarm?.setValue(numberOfQuestions, forKey: "numOfQuestionsToEnd")
        segueAlarm?.setValue(false, forKey: "snooze")
        segueAlarm?.setValue(selectSegmented(), forKey: "questionType")
        segueAlarm?.setValue(theAlarmSound, forKey: "alertSound")
        segueAlarm?.setValue(true, forKey: "on")

       managedObjectContext?.save(nil)

    }

    func createAlarm(alarmDate:NSDate) {

        let alarmName = alarmNameTextField.text as String
        let entity = NSEntityDescription.entityForName("Alarms", inManagedObjectContext:managedObjectContext!)
        let alarm = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        alarm.setValue(alarmName, forKey: "name")
        alarm.setValue(alarmDate, forKey: "time")
        alarm.setValue(numberOfQuestions, forKey: "numOfQuestionsToEnd")
        alarm.setValue(false, forKey: "snooze")
        alarm.setValue(selectSegmented(), forKey: "questionType")
        alarm.setValue(theAlarmSound, forKey: "alertSound")
        alarm.setValue(true, forKey: "on")
        println("\(alarm)")

        var error:NSError?
      managedObjectContext?.save(nil)

    }


    func selectSegmented () ->NSString {
        if questionTypeSegmentedControl.selectedSegmentIndex == 0 {
            typeOfQuestion =  "Random"
        }else if questionTypeSegmentedControl.selectedSegmentIndex == 1 {
            typeOfQuestion =  "Sports"
        }else if questionTypeSegmentedControl.selectedSegmentIndex == 2{
            typeOfQuestion =  "Movies"
        }else{
            typeOfQuestion = "Televsion"
        }

        return typeOfQuestion
    }
    @IBAction func subtractQuestionButtonPressed(sender: UIButton) {
        if numberOfQuestions == 1 {
            subtractQuesitonButton.hidden = true
            addQuestionButton.hidden = false
        }else if numberOfQuestions <= 5 {
            numberOfQuestions -= 1
            subtractQuesitonButton.hidden = false
            addQuestionButton.hidden = false
        }
        numberOfQuestionLabel.text? = String(numberOfQuestions)

    }
    @IBAction func addQuestionButtonPressed(sender: UIButton) {
        if numberOfQuestions == 5 {
            addQuestionButton.hidden = true
            subtractQuesitonButton.hidden = false
        }else if numberOfQuestions <= 4 {
            numberOfQuestions += 1
            subtractQuesitonButton.hidden = false
            addQuestionButton.hidden = false
        }

        numberOfQuestionLabel.text? = String(numberOfQuestions)
    }


    @IBAction func selectSoundButtonPressed(sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Sound", preferredStyle: .ActionSheet)

        // 2
        let bombSound = UIAlertAction(title: "Bomb Sound", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.theAlarmSound = "BombSound.wav"
        })
        let railRoad = UIAlertAction(title: "RailRoad Sound", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
             self.theAlarmSound = "railRoadSound.wav"
        })

        let alarmSound = UIAlertAction(title: "Default Alarm Sound", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.theAlarmSound = "LoudAlarm.wav"
        })

        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in

        })
        // 4
        optionMenu.addAction(bombSound)
        optionMenu.addAction(railRoad)
        optionMenu.addAction(alarmSound)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }


}
