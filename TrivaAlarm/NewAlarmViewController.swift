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
    var segueAlarm:Alarms?
    var theCoreDataStack: CoreDataStack!

    @IBOutlet weak var cancel: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.backgroundColor = UIColor(red: (49/255), green: (128/255), blue: (197/255), alpha: 1)
        datePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        // Do any additional setup after loading the view.
               subtractQuesitonButton.hidden = true
        self.navigationItem.leftBarButtonItem = cancel


        // set the Cancel button to white
      cancel.tintColor = UIColor.whiteColor()


        alarmNameTextField.delegate = self

        // if the User is segueing from an Alarm then take the info and add it to the VC

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

        // Hide the subtract button if the num of questions is 1
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

        let components = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: datePicker.date)

         let nowComponents = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: now)

        components.second = 0
        let zeroSecondDate:NSDate = calendar.dateFromComponents(components)!
        var alarmDate:NSDate
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .MediumStyle


            if calendar.isDate(zeroSecondDate, equalToDate: now, toUnitGranularity: .Hour) {
                if components.minute <= nowComponents.minute{

                    components.day = nowComponents.day + 1
                    alarmDate = calendar.dateFromComponents(components)!


                }else{
                     alarmDate = calendar.dateFromComponents(components)!
                }


            }else if components.hour < nowComponents.hour{
                components.day = nowComponents.day + 1
                alarmDate = calendar.dateFromComponents(components)!


            }else{
                alarmDate = zeroSecondDate
            }

        // if the segueAlarm is not nil then update it, other wise create a new alarm
        if segueAlarm != nil{
            editAlarm(alarmDate)
        }else{
            createAlarm(alarmDate)
        }
        navigationController?.popViewControllerAnimated(true)

    }

        func editAlarm(alarmDate:NSDate){
            if alarmNameTextField.text == ""{
                segueAlarm?.setValue("Wake Up", forKey: "name")
            }else{
                segueAlarm?.setValue(alarmNameTextField.text, forKey: "name")
            }

        segueAlarm?.setValue(alarmDate, forKey: "time")
        segueAlarm?.setValue(numberOfQuestions, forKey: "numOfQuestionsToEnd")
        segueAlarm?.setValue(false, forKey: "snooze")
        segueAlarm?.setValue(selectSegmented(), forKey: "questionType")
        segueAlarm?.setValue(theAlarmSound, forKey: "alertSound")
        segueAlarm?.setValue(true, forKey: "on")


            theCoreDataStack.saveMainContext()

    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func createAlarm(alarmDate:NSDate) {


        let entity = NSEntityDescription.entityForName("Alarms", inManagedObjectContext:theCoreDataStack.managedObjectContext)
        let alarm = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: theCoreDataStack.managedObjectContext)
        if alarmNameTextField.text == ""{
            alarm.setValue("Wake Up", forKey: "name")
        }else{
            alarm.setValue(alarmNameTextField.text, forKey: "name")
        }

        alarm.setValue(alarmDate, forKey: "time")
        alarm.setValue(numberOfQuestions, forKey: "numOfQuestionsToEnd")
        alarm.setValue(false, forKey: "snooze")
        alarm.setValue(selectSegmented(), forKey: "questionType")
        alarm.setValue(theAlarmSound, forKey: "alertSound")
        alarm.setValue(true, forKey: "on")
       
      theCoreDataStack.saveMainContext()

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
        let optionMenu = UIAlertController(title: "Sound", message: "Choose Sound", preferredStyle: .ActionSheet)

        if theAlarmSound == "BombSound.wav" {
        let bombSound = UIAlertAction(title: "Bomb Sound", style: .Destructive, handler: {
            (alert: UIAlertAction) -> Void in
            self.theAlarmSound = "BombSound.wav"

        })
             optionMenu.addAction(bombSound)
        }else {
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

        }else {
            let railRoad = UIAlertAction(title: "RailRoad Sound", style: .Default, handler: {
                (alert: UIAlertAction) -> Void in
                self.theAlarmSound = "railRoadSound.wav"
            })
            optionMenu.addAction(railRoad)

        }

        if theAlarmSound == "LoudAlarm.wav"{
        let alarmSound = UIAlertAction(title: "Default Alarm Sound", style: .Destructive, handler: {
            (alert: UIAlertAction) -> Void in
            self.theAlarmSound = "LoudAlarm.wav"


        })
            optionMenu.addAction(alarmSound)
        }else{
            let alarmSound = UIAlertAction(title: "Default Alarm Sound", style: .Default, handler: {
                (alert: UIAlertAction) -> Void in
                self.theAlarmSound = "LoudAlarm.wav"


            })
            optionMenu.addAction(alarmSound)
        }

        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in

        })

        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }


}
