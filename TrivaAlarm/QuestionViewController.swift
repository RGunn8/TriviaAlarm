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

    var theAlarm:Alarms?
    @IBOutlet weak var wrongLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var optionAButton: UIButton!
    @IBOutlet weak var numOfQuestionLabel: UILabel!


    @IBOutlet weak var optionCButton: UIButton!
    @IBOutlet weak var optionDButton: UIButton!
    @IBOutlet weak var optionBButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

               NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateVC:", name: "localNotficaionUserInfo", object: nil)
        optionAButton.titleLabel?.numberOfLines = 0
        optionBButton.titleLabel?.numberOfLines = 0
        optionCButton.titleLabel?.numberOfLines = 0
        optionDButton.titleLabel?.numberOfLines = 0
        navBar.delegate = self
        wrongLabel.hidden = true
        correctLabel.hidden = true
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)


          }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)

            NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition  {
        if (bar === self.navBar){
             println("move down")
           return UIBarPosition.TopAttached

        }
        return UIBarPosition.TopAttached
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

    func save() {
        var error:NSError?
        if managedObjectContext!.save(&error){
            println(error?.localizedDescription)
        }
    }

// Load View controller with alarm info
    func updateVC(notficaiton:NSNotification){

        var userInfo:Dictionary<String,String!> = notficaiton.userInfo as! Dictionary<String,String!>

        typeOfQuestion = userInfo["TypeOfQuestion"]!
        var numberOfQuestionString = userInfo["NumberOfQuestion"]

        println("The type of question is " + typeOfQuestion)

        let date = userInfo["AlarmDate"]!

        var alarmSoundWav = userInfo["AlarmSound"]!
        let rangeOfWav = Range(start: alarmSoundWav.startIndex,
            end: advance(alarmSoundWav.endIndex, -4))
        alarmSound = alarmSoundWav.substringWithRange(rangeOfWav)


        let soundURL = NSBundle.mainBundle().URLForResource(alarmSound, withExtension: "wav")

        audioPlayer = AVAudioPlayer(contentsOfURL: soundURL, error: nil)
        audioPlayer.play()


        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle

        theAlarmDate = dateFormatter.dateFromString(date)!
        numberOfQuestion = numberOfQuestionString!.toInt()!
        numOfQuestionLabel.text = "\(numberOfQuestion)"

        timer = NSTimer.scheduledTimerWithTimeInterval(10, target:self, selector: Selector("playSound"), userInfo: nil, repeats: true)
        fetchQuestions()

        fetchAlarm()

    }

    func playSound(){

        let soundURL = NSBundle.mainBundle().URLForResource(alarmSound, withExtension: "wav")
        
        audioPlayer = AVAudioPlayer(contentsOfURL: soundURL, error: nil)
        audioPlayer.play()
        
    }

    // Question tapped Methods

    @IBAction func optionAButtonPressed(sender: UIButton) {
        if theQuestion?.optionA == correctAnswer {

           numberOfQuestion = numberOfQuestion - 1
            numOfQuestionLabel.text = "\(numberOfQuestion)"
            correctLabel.hidden = false
            wrongLabel.hidden = true

        }else{
            //numberOfQuestion = numberOfQuestion + 1
             numOfQuestionLabel.text = "\(numberOfQuestion)"
            wrongLabel.hidden = false
            correctLabel.hidden = true

        }

       randomIndex()

        if numberOfQuestion == 0 {
            self.dismissViewControllerAnimated(true, completion: {});
            // self.performSegueWithIdentifier("finishAlarm", sender: self)
            UIApplication.sharedApplication().cancelAllLocalNotifications()
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
            correctLabel.hidden = false
            wrongLabel.hidden = false

        }else{
            //numberOfQuestion = numberOfQuestion + 1
             numOfQuestionLabel.text = "\(numberOfQuestion)"
            wrongLabel.hidden = false
            correctLabel.hidden = true

        }
        randomIndex()
        if numberOfQuestion == 0 {
            self.dismissViewControllerAnimated(true, completion: {});
            //self.performSegueWithIdentifier("finishAlarm", sender: self)
            UIApplication.sharedApplication().cancelAllLocalNotifications()
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
            correctLabel.hidden = false
            wrongLabel.hidden = true

        }else{
            //numberOfQuestion = numberOfQuestion + 1
             numOfQuestionLabel.text = "\(numberOfQuestion)"
            wrongLabel.hidden = false
            correctLabel.hidden = true

        }
        randomIndex()

        if numberOfQuestion == 0 {
            self.dismissViewControllerAnimated(true, completion: {});
            //self.performSegueWithIdentifier("finishAlarm", sender: self)
             UIApplication.sharedApplication().cancelAllLocalNotifications()
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
            correctLabel.hidden = false
            wrongLabel.hidden = true


        }else{
            //numberOfQuestion = numberOfQuestion
             numOfQuestionLabel.text = "\(numberOfQuestion)"
            wrongLabel.hidden = false
            correctLabel.hidden = true


        }
       

        randomIndex()
        if numberOfQuestion == 0 {
           self.dismissViewControllerAnimated(true, completion: {});
            // self.performSegueWithIdentifier("finishAlarm", sender: self)
             UIApplication.sharedApplication().cancelAllLocalNotifications()
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
            if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Questions] {
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
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Questions] {
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


func fetchAlarm() {
    let fetchAlarm = NSFetchRequest(entityName: "Alarms")


     let firstPredicate = NSPredicate(format: "time == %@", theAlarmDate)
        fetchAlarm.predicate = firstPredicate


    if let fetchAlarm = managedObjectContext!.executeFetchRequest(fetchAlarm, error: nil) as? [Alarms] {
        alarm = fetchAlarm
        theAlarm = alarm[0]
         }
}
}
