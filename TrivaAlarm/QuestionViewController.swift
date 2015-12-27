//
//  QuestionViewController.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 7/27/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
class QuestionViewController: UIViewController, UINavigationBarDelegate {
    @IBOutlet weak var navBar: UINavigationBar!
    var numberOfQuestion = Int()
    var typeOfQuestion = "Random"
    var audioPlayer: AVAudioPlayer!
    var coreDataStack: CoreDataStack!
    var questions = [Questions]()
    var alarmSound = String()
    var notficationSound = String()
    var correctAnswer = String()
    var theQuestion: Questions?
    var alarm = [Alarms]()
    var theAlarmDate = NSDate()
    var timer = NSTimer()
    var isZero = false
    @IBOutlet var alarmNumberOfQuestionLeftView: UIView!
    @IBOutlet var answerLabel: UILabel!
    var theAlarm: Alarms?
    @IBOutlet weak var optionAButton: UIButton!
    @IBOutlet weak var numOfQuestionLabel: UILabel!


    @IBOutlet weak var optionCButton: UIButton!
    @IBOutlet weak var optionDButton: UIButton!
    @IBOutlet weak var optionBButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

      alarmNumberOfQuestionLeftView.layer.borderColor = UIColor(red: (49/255), green: (128/255), blue: (197/255), alpha: 1).CGColor
        // Set navbar 20 points and then set delegeate to attach to the top
        self.navBar.delegate = self

        optionAButton.titleLabel?.numberOfLines = 0
        optionBButton.titleLabel?.numberOfLines = 0
        optionCButton.titleLabel?.numberOfLines = 0
        optionDButton.titleLabel?.numberOfLines = 0

        // Add notfication to get questions and update the view controller

         NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateVC:", name: "localNotficaionUserInfo", object: nil)

        // Notfication for when the app goes into the foreground
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "alarmToBack",
            name: "alarmGoesToBackground",
            object: nil)


        answerLabel.hidden = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {

            let alertViewControler = UIAlertController(title: "Error has Occured", message: "An audio issues has occued \(error)", preferredStyle: .Alert)

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
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
            NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    // Give a user a chance to exit without answer the questions if they are need to turn it off

        @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {})
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        timer.invalidate()

            if let theAlarm = theAlarm {
                if theAlarm.hasReminder {
                    theAlarm.on = true
                } else {
                    theAlarm.on = false
                }
            }

        isZero = true
        audioPlayer.stop()
        coreDataStack.saveMainContext()

    }

    // When the app goes to the background create two local notfication so they can return to the app

    func alarmToBack() {
        let notification = UILocalNotification()
        notification.alertBody = "You Still have Questions Left" // text that will be displayed in the notification
        notification.fireDate =  NSDate() // notficaiton fire off right when app goes into forgeground
        notification.soundName = notficationSound
        notification.timeZone = NSCalendar.currentCalendar().timeZone
        notification.repeatInterval = NSCalendarUnit.Minute
        var userInfo: [String: String] = [String: String]()

        let numOfQuestion = "\(numberOfQuestion)" as String
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.LongStyle
        let alarmDate = formatter.stringFromDate(theAlarmDate)

        print("alarm to back has been called")

        // Fill in the userinfo dictonary so when the user comes back they know how info for the VC

        userInfo["NumberOfQuestion"] = numOfQuestion ?? "1"

        userInfo["TypeOfQuestion"] = typeOfQuestion ?? "Random"

        userInfo["AlarmDate"] = alarmDate ?? "nil"

        userInfo["AlarmSound"] = notficationSound ?? "LoudAlarm.wav"

        notification.userInfo = userInfo


        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        let notification2 = UILocalNotification()

        let notification2Date: NSDate = NSDate().dateByAddingTimeInterval(30)
        notification2.alertBody = "You Still have Questions Left" // text that will be displayed in the notification
        notification2.fireDate =  notification2Date
        notification2.soundName = notficationSound
        notification2.timeZone = NSCalendar.currentCalendar().timeZone
        notification2.repeatInterval = NSCalendarUnit.Minute

        notification2.userInfo = userInfo
        UIApplication.sharedApplication().scheduleLocalNotification(notification2)

        // Dimiss view controller so a new VC can be created

        self.dismissViewControllerAnimated(true, completion: {})
        // Stop timer so the sound will stop
       timer.invalidate()
        audioPlayer.stop()
    }




    func cancelAlarmNotificaion() {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]!
        for notificaion in notifications {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = NSDateFormatterStyle.LongStyle
            let alarmDate = formatter.stringFromDate(theAlarm!.time)
            if let notifDate = notificaion.userInfo?["AlarmDate"] as? String {
                if alarmDate == notifDate {
                    UIApplication.sharedApplication().cancelLocalNotification(notificaion)
                }
            }
        }
    }

// Load View controller with alarm info
    func updateVC(notficaiton: NSNotification) {
        var numOfTimeupdateVCCalled = 0
        if numOfTimeupdateVCCalled == 0 {
            guard let userInfo = notficaiton.userInfo as? Dictionary<String,String> else {
                return
            }

            typeOfQuestion = userInfo["TypeOfQuestion"]!
            let numberOfQuestionString = userInfo["NumberOfQuestion"]

            let date = userInfo["AlarmDate"]!

            let alarmSoundWav = userInfo["AlarmSound"]!
            notficationSound = userInfo["AlarmSound"]!
            let rangeOfWav = Range(start: alarmSoundWav.startIndex,
                end: alarmSoundWav.endIndex.advancedBy(-4))
            alarmSound = alarmSoundWav.substringWithRange(rangeOfWav)


            let soundURL = NSBundle.mainBundle().URLForResource(alarmSound, withExtension: "wav")

            audioPlayer = try? AVAudioPlayer(contentsOfURL: soundURL!)
            audioPlayer.play()


            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle

            theAlarmDate = dateFormatter.dateFromString(date)!
            numberOfQuestion = Int(numberOfQuestionString!)!
            numOfQuestionLabel.text = "\(numberOfQuestion)"

            // Create timer so the sound keep playing
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("playSound"), userInfo: nil, repeats: true)
            fetchQuestions()
            fetchAlarm()
        numOfTimeupdateVCCalled += 1

        }

    }

    func playSound() {
        let soundURL = NSBundle.mainBundle().URLForResource(alarmSound, withExtension: "wav")
        audioPlayer = try? AVAudioPlayer(contentsOfURL: soundURL!)
        audioPlayer.play()
    }

    // Question tapped Methods

    @IBAction func optionAButtonPressed(sender: UIButton) {
        if theQuestion?.optionA == correctAnswer {
           correctAnswersSelected()

        }else {
           wrongAnswer()

        }

       randomIndex()

        if numberOfQuestion == 0 {
         numOfQuestionIsZero()
        }
    }

    @IBAction func optionBButtonPressed(sender: UIButton) {
        if theQuestion?.optionB == correctAnswer {
            correctAnswersSelected()

        }else {
           wrongAnswer()


        }
        randomIndex()
        if numberOfQuestion == 0 {
           numOfQuestionIsZero()
        }

    }

    @IBAction func optionCButtonPressed(sender: UIButton) {
        if theQuestion?.optionC == correctAnswer {
            correctAnswersSelected()

        }else {
           wrongAnswer()

        }
        randomIndex()

        if numberOfQuestion == 0 {
        numOfQuestionIsZero()

        }

    }

    @IBAction func optionDButtonPressed(sender: UIButton) {
        if theQuestion?.optionD == correctAnswer {
            correctAnswersSelected()
        }else {
            wrongAnswer()
        }
        randomIndex()
        if numberOfQuestion == 0 {
          numOfQuestionIsZero()

        }


    }

    func wrongAnswer() {
        numOfQuestionLabel.text = "\(numberOfQuestion)"
        answerLabel.backgroundColor = UIColor.redColor()
        answerLabel.hidden = false
        answerLabel.text = "Incorrect"
        answerLabel.textColor = UIColor.whiteColor()

    }

    func correctAnswersSelected() {
        numberOfQuestion = numberOfQuestion  - 1
        numOfQuestionLabel.text = "\(numberOfQuestion)"

        answerLabel.backgroundColor = UIColor.greenColor()
        answerLabel.hidden = false
        answerLabel.text = "Correct"
        answerLabel.textColor = UIColor.whiteColor()
    }

    func numOfQuestionIsZero() {
        self.dismissViewControllerAnimated(true, completion: {})
        cancelAlarmNotificaion()
        timer.invalidate()
        if let theAlarm = theAlarm {
            if theAlarm.hasReminder {
                theAlarm.on = true
            } else {
                theAlarm.on = false
            }
        }

        isZero = true
        audioPlayer.stop()
        coreDataStack.saveMainContext()
    }

// Get a random Questions form the questions Array
    func randomIndex() {
        let randomIndex = Int(arc4random_uniform(UInt32(questions.count)))
        theQuestion = questions[randomIndex]
        if let theQuestion = theQuestion {
            questionLabel.text = theQuestion.question
            optionAButton.setTitle(theQuestion.optionA, forState: .Normal)
            optionBButton.setTitle(theQuestion.optionB, forState: .Normal)
            optionCButton.setTitle(theQuestion.optionC, forState: .Normal)
            optionDButton.setTitle(theQuestion.optionD, forState: .Normal)
            correctAnswer = theQuestion.correctAnswer

        }
    }

// Fetched Questions and alrms
    func fetchQuestions() {
        let fetchRequest = NSFetchRequest(entityName: "Questions")

        // If it random then selected any question, other wise seleced a question from a category

        if typeOfQuestion != "Random" {
            let firstPredicate = NSPredicate(format: "type == %@", typeOfQuestion)
            fetchRequest.predicate = firstPredicate

            if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Questions] {
                questions = fetchResults

                let randomIndex = Int(arc4random_uniform(UInt32(questions.count)))
                theQuestion = questions[randomIndex]
                if let theQuestion = theQuestion {

                    questionLabel.text = theQuestion.question
                    optionAButton.setTitle(theQuestion.optionA, forState: .Normal)
                    optionBButton.setTitle(theQuestion.optionB, forState: .Normal)
                    optionCButton.setTitle(theQuestion.optionC, forState: .Normal)
                    optionDButton.setTitle(theQuestion.optionD, forState: .Normal)
                    correctAnswer = theQuestion.correctAnswer
                }

            }

        } else {
        if let fetchResults = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Questions] {
            questions = fetchResults

            let randomIndex = Int(arc4random_uniform(UInt32(questions.count)))
            theQuestion = questions[randomIndex]
            if let theQuestion = theQuestion {

                questionLabel.text = theQuestion.question
                optionAButton.setTitle(theQuestion.optionA, forState: .Normal)
                optionBButton.setTitle(theQuestion.optionB, forState: .Normal)
                optionCButton.setTitle(theQuestion.optionC, forState: .Normal)
                optionDButton.setTitle(theQuestion.optionD, forState: .Normal)
                correctAnswer = theQuestion.correctAnswer
                }
            }
        }
    }

    // Fetch the Alarm
    func fetchAlarm() {
        let fetchAlarm = NSFetchRequest(entityName: "Alarms")
        let firstPredicate = NSPredicate(format: "time == %@", theAlarmDate)
        fetchAlarm.predicate = firstPredicate


        if let fetchAlarm = (try? coreDataStack.managedObjectContext.executeFetchRequest(fetchAlarm)) as? [Alarms] {
            alarm = fetchAlarm
            theAlarm = alarm[0]
        }
    }



    // Status bar turns to white

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}

// Nav Bar delegate
extension QuestionViewController: UIBarPositioningDelegate {

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }

}
