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
    var audioPlayer:AVAudioPlayer!
     var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var questions = [Questions]()
    var alarmSound = String()
    var notficationSound = String()
    var correctAnswer = String()
    var theQuestion:Questions?
    var alarm = [Alarms]()
    var theAlarmDate = NSDate()
    var timer = NSTimer()
    var isZero = false


    @IBOutlet var alarmNumberOfQuestionLeftView: UIView!
    
    @IBOutlet var answerLabel: UILabel!
    var theAlarm:Alarms?
    @IBOutlet weak var optionAButton: UIButton!
    @IBOutlet weak var numOfQuestionLabel: UILabel!


    @IBOutlet weak var optionCButton: UIButton!
    @IBOutlet weak var optionDButton: UIButton!
    @IBOutlet weak var optionBButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()


      alarmNumberOfQuestionLeftView.layer.borderColor = UIColor(red: (49/255), green: (128/255), blue: (197/255), alpha: 1).CGColor
        self.navBar.delegate = self

        optionAButton.titleLabel?.numberOfLines = 0
        optionBButton.titleLabel?.numberOfLines = 0
        optionCButton.titleLabel?.numberOfLines = 0
        optionDButton.titleLabel?.numberOfLines = 0

         NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateVC:", name: "localNotficaionUserInfo", object: nil)


        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "alarmToBack",
            name: "alarmGoesToBackground",
            object: nil)


 
        answerLabel.hidden = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }


          }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)

            NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

        @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: {});
        //self.performSegueWithIdentifier("finishAlarm", sender: self)
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        timer.invalidate()
        theAlarm!.on = false
        isZero = true
        audioPlayer.stop()
        save()

    }
    
    func alarmToBack() {
        let notification = UILocalNotification()

        notification.alertBody = "You Still have Questions Left" // text that will be displayed in the notification
        notification.fireDate =  NSDate() // todo item due date (when notification will be fired)
        notification.soundName = notficationSound
        notification.timeZone = NSCalendar.currentCalendar().timeZone
        notification.repeatInterval = NSCalendarUnit.Minute
        var userInfo:[String:String] = [String:String]()

        let numOfQuestion = "\(numberOfQuestion)" as String
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.LongStyle
        let alarmDate = formatter.stringFromDate(theAlarmDate)

        userInfo["NumberOfQuestion"] = numOfQuestion ?? "1"

        userInfo["TypeOfQuestion"] = typeOfQuestion ?? "Random"

        userInfo["AlarmDate"] = alarmDate ?? "nil"

        userInfo["AlarmSound"] = notficationSound ?? "LoudAlarm.wav"

        notification.userInfo = userInfo


        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        let notification2 = UILocalNotification()

        let notification2Date:NSDate = NSDate().dateByAddingTimeInterval(30)
        notification2.alertBody = "You Still have Questions Left" // text that will be displayed in the notification
        notification2.fireDate =  notification2Date // todo item due date (when notification will be fired)
        notification2.soundName = notficationSound
        notification2.timeZone = NSCalendar.currentCalendar().timeZone
        notification2.repeatInterval = NSCalendarUnit.Minute

        notification2.userInfo = userInfo
        UIApplication.sharedApplication().scheduleLocalNotification(notification2)

        self.dismissViewControllerAnimated(true, completion: {});
        // self.performSegueWithIdentifier("finishAlarm", sender: self)
        //cancelAlarmNotificaion()
       timer.invalidate()
//        theAlarm!.on = false
       // isZero = true
        audioPlayer.stop()
       // save()
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

    func cancelAlarmNotificaion() {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]!
        for notificaion in notifications{
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = NSDateFormatterStyle.LongStyle
            let alarmDate = formatter.stringFromDate(theAlarm!.time)
            if let notifDate = notificaion.userInfo?["AlarmDate"] as? String{
                if alarmDate == notifDate{
                    UIApplication.sharedApplication().cancelLocalNotification(notificaion)

                }
            }
        }
    }

// Load View controller with alarm info
    func updateVC(notficaiton:NSNotification){

        var userInfo:Dictionary<String,String!> = notficaiton.userInfo as! Dictionary<String,String!>

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

        timer = NSTimer.scheduledTimerWithTimeInterval(10, target:self, selector: Selector("playSound"), userInfo: nil, repeats: true)
        fetchQuestions()

        fetchAlarm()

    }

    func playSound(){

        let soundURL = NSBundle.mainBundle().URLForResource(alarmSound, withExtension: "wav")
        
        audioPlayer = try? AVAudioPlayer(contentsOfURL: soundURL!)
        audioPlayer.play()
        
    }

    // Question tapped Methods

    @IBAction func optionAButtonPressed(sender: UIButton) {
        if theQuestion?.optionA == correctAnswer {

           numberOfQuestion = numberOfQuestion - 1
            numOfQuestionLabel.text = "\(numberOfQuestion)"


            answerLabel.backgroundColor = UIColor.greenColor()
            answerLabel.hidden = false
            answerLabel.text = "Correct"
            answerLabel.textColor = UIColor.whiteColor()

        }else{
            //numberOfQuestion = numberOfQuestion + 1
             numOfQuestionLabel.text = "\(numberOfQuestion)"


            answerLabel.backgroundColor = UIColor.redColor()
            answerLabel.hidden = false
            answerLabel.text = "Incorrect"
            answerLabel.textColor = UIColor.whiteColor()

        }

       randomIndex()

        if numberOfQuestion == 0 {
            self.dismissViewControllerAnimated(true, completion: {});
            // self.performSegueWithIdentifier("finishAlarm", sender: self)
            cancelAlarmNotificaion()
            timer.invalidate()
            theAlarm!.on = false
            isZero = true
            audioPlayer.stop()
            save()
           
        }
    }

    @IBAction func optionBButtonPressed(sender: UIButton) {
        if theQuestion?.optionB == correctAnswer {

            numberOfQuestion = numberOfQuestion  - 1
            numOfQuestionLabel.text = "\(numberOfQuestion)"

            answerLabel.backgroundColor = UIColor.greenColor()
            answerLabel.hidden = false
            answerLabel.text = "Correct"
            answerLabel.textColor = UIColor.whiteColor()

        }else{
            //numberOfQuestion = numberOfQuestion + 1
             numOfQuestionLabel.text = "\(numberOfQuestion)"

            answerLabel.backgroundColor = UIColor.redColor()
            answerLabel.hidden = false
            answerLabel.text = "Incorrect"
            answerLabel.textColor = UIColor.whiteColor()


        }
        randomIndex()
        if numberOfQuestion == 0 {
            self.dismissViewControllerAnimated(true, completion: {});
            //self.performSegueWithIdentifier("finishAlarm", sender: self)
           cancelAlarmNotificaion()
            theAlarm!.on = false
            isZero = true
            timer.invalidate()
            audioPlayer.stop()
            save()

        }

    }

    
    @IBAction func optionCButtonPressed(sender: UIButton) {
        if theQuestion?.optionC == correctAnswer {

            numberOfQuestion = numberOfQuestion - 1
            numOfQuestionLabel.text = "\(numberOfQuestion)"
            answerLabel.backgroundColor = UIColor.greenColor()
            answerLabel.hidden = false
            answerLabel.text = "Correct"
            answerLabel.textColor = UIColor.whiteColor()

        }else{
            //numberOfQuestion = numberOfQuestion + 1
             numOfQuestionLabel.text = "\(numberOfQuestion)"
            answerLabel.backgroundColor = UIColor.redColor()
            answerLabel.hidden = false
            answerLabel.text = "Incorrect"
            answerLabel.textColor = UIColor.whiteColor()

        }
        randomIndex()

        if numberOfQuestion == 0 {
            self.dismissViewControllerAnimated(true, completion: {});
            //self.performSegueWithIdentifier("finishAlarm", sender: self)
           cancelAlarmNotificaion()
            timer.invalidate()
            theAlarm!.on = false
            isZero = true
            audioPlayer.stop()
            save()

        }

    }

    @IBAction func optionDButtonPressed(sender: UIButton) {
        if theQuestion?.optionD == correctAnswer {

            numberOfQuestion = numberOfQuestion - 1
            numOfQuestionLabel.text = "\(numberOfQuestion)"
            answerLabel.backgroundColor = UIColor.greenColor()
            answerLabel.hidden = false
            answerLabel.text = "Correct"
            answerLabel.textColor = UIColor.whiteColor()


        }else{
            //numberOfQuestion = numberOfQuestion
             numOfQuestionLabel.text = "\(numberOfQuestion)"
            answerLabel.backgroundColor = UIColor.redColor()
            answerLabel.hidden = false
            answerLabel.text = "Incorrect"
            answerLabel.textColor = UIColor.whiteColor()


        }
       

        randomIndex()
        if numberOfQuestion == 0 {
           self.dismissViewControllerAnimated(true, completion: {});
          cancelAlarmNotificaion()
            theAlarm!.on = false
            timer.invalidate()
            audioPlayer.stop()
            save()

        }


    }


    func randomIndex(){
        let randomIndex = Int(arc4random_uniform(UInt32(questions.count)))
        theQuestion = questions[randomIndex]
        if let theQuestion = theQuestion{

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

        if typeOfQuestion != "Random" {
            let firstPredicate = NSPredicate(format: "type == %@", typeOfQuestion)
            fetchRequest.predicate = firstPredicate
            if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Questions] {
                questions = fetchResults

                let randomIndex = Int(arc4random_uniform(UInt32(questions.count)))
                theQuestion = questions[randomIndex]
                if let theQuestion = theQuestion{

                    questionLabel.text = theQuestion.question
                    optionAButton.setTitle(theQuestion.optionA, forState: .Normal)
                    optionBButton.setTitle(theQuestion.optionB, forState: .Normal)
                    optionCButton.setTitle(theQuestion.optionC, forState: .Normal)
                    optionDButton.setTitle(theQuestion.optionD, forState: .Normal)
                    correctAnswer = theQuestion.correctAnswer
                    
                }

            }

        }else {
        
        if let fetchResults = (try? managedObjectContext!.executeFetchRequest(fetchRequest)) as? [Questions] {
            questions = fetchResults

            let randomIndex = Int(arc4random_uniform(UInt32(questions.count)))
            theQuestion = questions[randomIndex]
            if let theQuestion = theQuestion{

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

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

func fetchAlarm() {
    let fetchAlarm = NSFetchRequest(entityName: "Alarms")


     let firstPredicate = NSPredicate(format: "time == %@", theAlarmDate)
        fetchAlarm.predicate = firstPredicate


    if let fetchAlarm = (try? managedObjectContext!.executeFetchRequest(fetchAlarm)) as? [Alarms] {
        alarm = fetchAlarm
        theAlarm = alarm[0]
         }
}
}


extension QuestionViewController : UIBarPositioningDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}
