//
//  NewAlarmViewController.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 7/22/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData

class NewAlarmViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var alarmNameTextField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var numberOfQuestionLabel: UILabel!
    @IBOutlet var addQuestionButton: UIButton!
    @IBOutlet var subtractQuesitonButton: UIButton!
    @IBOutlet var questionTypeSegmentedControl: UISegmentedControl!
    var numberOfQuestions = 1
    var typeOfQuestion = "Random"
    var theAlarmSound = "LoudAlarm.wav"
    var segueAlarm: Alarms?
    var theCoreDataStack: CoreDataStack!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet var repeatSwitchButton: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        setDatePicker()
               subtractQuesitonButton.hidden = true
        self.navigationItem.leftBarButtonItem = cancel

      cancel.tintColor = UIColor.whiteColor()
        alarmNameTextField.delegate = self

    }

    func setDatePicker() {
        datePicker.backgroundColor = UIColor(red: (49/255), green: (128/255), blue: (197/255), alpha: 1)
        datePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")

    }

    func loadSegueAlarm() {
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

        setSubtractButton()

    }

    func setSubtractButton() {
        if numberOfQuestions == 1 {

            subtractQuesitonButton.hidden = true
        }else {
            subtractQuesitonButton.hidden = false
        }

        if numberOfQuestions == 5 {
            addQuestionButton.hidden = true
        } else {
            addQuestionButton.hidden = false
        }

    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }


    @IBAction func cancelButtonPressed(sender: AnyObject) {
       navigationController?.popViewControllerAnimated(true)
    }

    func setAlarmDate() -> NSDate {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: datePicker.date)
        let nowComponents = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: now)

        components.second = 0
        let zeroSecondDate: NSDate = calendar.dateFromComponents(components)!
        var alarmDate: NSDate
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .MediumStyle
        if calendar.isDate(zeroSecondDate, equalToDate: now, toUnitGranularity: .Hour) {
            if components.minute <= nowComponents.minute {

                components.day = nowComponents.day + 1
                alarmDate = calendar.dateFromComponents(components)!
            }else {
                alarmDate = calendar.dateFromComponents(components)!
            }

        }else if components.hour < nowComponents.hour {
            components.day = nowComponents.day + 1
            alarmDate = calendar.dateFromComponents(components)!
        } else {
            alarmDate = zeroSecondDate
        }

        return alarmDate
    }

    @IBAction func saveButton(sender: UIBarButtonItem) {

        // if the segueAlarm is not nil then update it, other wise create a new alarm
        if segueAlarm != nil {
            editAlarm()
        }else {
            createAlarm()
        }
        navigationController?.popViewControllerAnimated(true)
    }

    func editAlarm() {
            if alarmNameTextField.text == "" {
                segueAlarm?.setValue("Wake Up", forKey: "name")
            } else {
                segueAlarm?.setValue(alarmNameTextField.text, forKey: "name")
            }

        segueAlarm?.setValue(setAlarmDate(), forKey: "time")
        segueAlarm?.setValue(numberOfQuestions, forKey: "numOfQuestionsToEnd")
        segueAlarm?.setValue(selectSegmented(), forKey: "questionType")
        segueAlarm?.setValue(theAlarmSound, forKey: "alertSound")
        segueAlarm?.setValue(true, forKey: "on")
        theCoreDataStack.saveMainContext()

    }

    func createAlarm() {
        let entity = NSEntityDescription.entityForName("Alarms", inManagedObjectContext: theCoreDataStack.managedObjectContext)
        let alarm = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: theCoreDataStack.managedObjectContext)
        if alarmNameTextField.text == "" {
            alarm.setValue("Wake Up", forKey: "name")
        }else {
            alarm.setValue(alarmNameTextField.text, forKey: "name")
        }
        alarm.setValue(setAlarmDate(), forKey: "time")
        alarm.setValue(numberOfQuestions, forKey: "numOfQuestionsToEnd")
        alarm.setValue(selectSegmented(), forKey: "questionType")
        alarm.setValue(theAlarmSound, forKey: "alertSound")
        alarm.setValue(true, forKey: "on")
      theCoreDataStack.saveMainContext()

    }

    func selectSegmented () -> NSString {
        if questionTypeSegmentedControl.selectedSegmentIndex == 0 {
            typeOfQuestion =  "Random"
        }else if questionTypeSegmentedControl.selectedSegmentIndex == 1 {
            typeOfQuestion =  "Sports"
        }else if questionTypeSegmentedControl.selectedSegmentIndex == 2 {
            typeOfQuestion =  "Movies"
        }else {
            typeOfQuestion = "Televsion"
        }

        return typeOfQuestion
    }

    @IBAction func subtractQuestionButtonPressed(sender: UIButton) {
       setSubtractButton()
        numberOfQuestionLabel.text? = String(numberOfQuestions)
    }

    @IBAction func addQuestionButtonPressed(sender: UIButton) {
      setSubtractButton()
        numberOfQuestionLabel.text? = String(numberOfQuestions)
    }

    @IBAction func selectSoundButtonPressed(sender: UIButton) {
        let optionMenu = UIAlertController(title: "Sound", message: "Choose Sound", preferredStyle: .ActionSheet)

        if theAlarmSound == "BombSound.wav" {
        let bombSound = UIAlertAction(title: "Bomb Sound", style: .Destructive, handler: {
            (alert: UIAlertAction) -> Void in
            self.theAlarmSound = "BombSound.wav"

        })
             optionMenu.addAction(bombSound)
        } else {
            let bombSound = UIAlertAction(title: "Bomb Sound", style: .Default, handler: {
                (alert: UIAlertAction) -> Void in
                self.theAlarmSound = "BombSound.wav"

            })
            optionMenu.addAction(bombSound)

        }

        if theAlarmSound == "railRoadSound.wav" {

        let railRoad = UIAlertAction(title: "RailRoad Sound", style: .Destructive, handler: {
            (alert: UIAlertAction) -> Void in
             self.theAlarmSound = "railRoadSound.wav"
        })
             optionMenu.addAction(railRoad)

        } else {
            let railRoad = UIAlertAction(title: "RailRoad Sound", style: .Default, handler: {
                (alert: UIAlertAction) -> Void in
                self.theAlarmSound = "railRoadSound.wav"
            })
            optionMenu.addAction(railRoad)
        }

        if theAlarmSound == "LoudAlarm.wav" {

        let alarmSound = UIAlertAction(title: "Default Alarm Sound", style: .Destructive, handler: {
            (alert: UIAlertAction) -> Void in
            self.theAlarmSound = "LoudAlarm.wav"
        })
            optionMenu.addAction(alarmSound)
        } else {
            let alarmSound = UIAlertAction(title: "Default Alarm Sound", style: .Default, handler: {
                (alert: UIAlertAction) -> Void in
                self.theAlarmSound = "LoudAlarm.wav"
            })
            optionMenu.addAction(alarmSound)

        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in

        })

       optionMenu.addAction(cancelAction)
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }


    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
