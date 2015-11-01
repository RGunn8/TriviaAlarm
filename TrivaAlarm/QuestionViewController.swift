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
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateVC:", name: "localNotficaionUserInfo", object: nil)
        optionAButton.titleLabel?.numberOfLines = 0
        optionBButton.titleLabel?.numberOfLines = 0
        optionCButton.titleLabel?.numberOfLines = 0
        optionDButton.titleLabel?.numberOfLines = 0
      
//        wrongLabel.hidden = true
//        correctLabel.hidden = true
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

    func setRootController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionVC") as! ViewController
        let frame = UIScreen.mainScreen().bounds
       let appDelegate = UIApplication.sharedApplication().delegate
    }

    func save() {
        var error:NSError?
        do {
            try managedObjectContext!.save()
            if error != nil {
            print(error?.localizedDescription)
            }
        } catch let error1 as NSError {
            error = error1
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
                    print("\(notificaion)")
                }
            }
        }
    }

// Load View controller with alarm info
    func updateVC(notficaiton:NSNotification){

        var userInfo:Dictionary<String,String!> = notficaiton.userInfo as! Dictionary<String,String!>

        typeOfQuestion = userInfo["TypeOfQuestion"]!
        let numberOfQuestionString = userInfo["NumberOfQuestion"]

        print("The type of question is " + typeOfQuestion)

        let date = userInfo["AlarmDate"]!

        let alarmSoundWav = userInfo["AlarmSound"]!
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
