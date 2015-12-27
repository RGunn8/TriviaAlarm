//
//  AppDelegate.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 7/22/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

     lazy var coreDataStack = CoreDataStack()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.cancelAllLocalNotifications()
        guard let rootViewController = self.window?.rootViewController as? UINavigationController else {
            return false
        }
        guard let viewController = rootViewController.topViewController as? ViewController else {
            return false
        }
        if viewController.respondsToSelector("setCoreDataStack:") {
            viewController.performSelector("setCoreDataStack:", withObject: coreDataStack)
        }

        UINavigationBar.appearance().barTintColor = UIColor(red: (49/255), green: (128/255), blue: (197/255), alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        let defaults = NSUserDefaults.standardUserDefaults()
        let isPreloaded = defaults.boolForKey("isPreloaded")
        if !isPreloaded {
            preloadData()
            defaults.setBool(true, forKey: "isPreloaded")
        }

        let firstLoad = defaults.boolForKey("firstLoad")
        if !firstLoad {
            createFirstAlarm()
            defaults.setBool(true, forKey: "firstLoad")
        }

        UINavigationBar.appearance().barStyle = .Black

        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil))

        if let options = launchOptions {

            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                      dispatch_async(dispatch_get_main_queue(), {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionVC") as? QuestionViewController else {
                            return
                        }

                        vc.coreDataStack = self.coreDataStack
                        self.window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
                        guard let notificationUserInfo = notification.userInfo  else {
                            return
                        }
                        guard let numbOfQuestion: AnyObject = notificationUserInfo["NumberOfQuestion"] else {
                            return
                        }
                        guard let typeOfQuestion: AnyObject = notification.userInfo!["TypeOfQuestion"] else {
                            return
                        }
                        guard let alarmDate: AnyObject = notification.userInfo!["AlarmDate"] else {
                            return
                        }
                        guard let alarmSound: AnyObject = notification.userInfo!["AlarmSound"] else {
                            return
                        }
                        let nc = NSNotificationCenter.defaultCenter()
                        nc.postNotificationName("localNotficaionUserInfo", object: nil, userInfo: ["NumberOfQuestion": numbOfQuestion , "TypeOfQuestion": typeOfQuestion, "AlarmDate": alarmDate, "AlarmSound": alarmSound])
                        application.cancelLocalNotification(notification)

                })

                 application.cancelLocalNotification(notification)
            }
        }

        return true
    }

    func createFirstAlarm() {
        let entity = NSEntityDescription.entityForName("Alarms", inManagedObjectContext: coreDataStack.managedObjectContext)
        let alarm = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: coreDataStack.managedObjectContext)

        alarm.setValue("Wake Up", forKey: "name")
        alarm.setValue(NSDate(), forKey: "time")
        alarm.setValue(1, forKey: "numOfQuestionsToEnd")
        alarm.setValue("Random", forKey: "questionType")
        alarm.setValue("LoudAlarm.wav", forKey: "alertSound")
        alarm.setValue(false, forKey: "on")

        coreDataStack.saveMainContext()
    }

    func notficationRecieveSetup(notification: UILocalNotification) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionVC") as? QuestionViewController else {
            return
        }
        vc.coreDataStack = self.coreDataStack
        self.window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
        guard let notificationUserInfo = notification.userInfo  else {
            return
        }
        guard let numbOfQuestion: AnyObject = notificationUserInfo["NumberOfQuestion"] else {
            return
        }
        guard let typeOfQuestion: AnyObject = notification.userInfo!["TypeOfQuestion"] else {
            return
        }
        guard let alarmDate: AnyObject = notification.userInfo!["AlarmDate"] else {
            return
        }
        guard let alarmSound: AnyObject = notification.userInfo!["AlarmSound"] else {
            return
        }
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("localNotficaionUserInfo", object: nil, userInfo: ["NumberOfQuestion": numbOfQuestion , "TypeOfQuestion": typeOfQuestion, "AlarmDate": alarmDate, "AlarmSound": alarmSound])

    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
            application.cancelAllLocalNotifications()
           notficationRecieveSetup(notification)


    }

    func parseCSV (contentsOfURL: NSURL, encoding: NSStringEncoding) throws -> [(question: String, type: String, optionA: String, optionB: String, optionC: String, optionD: String, correctAnswer: String)] {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        // Load the CSV file and parse it
        let delimiter = ","
        var items: [(question: String, type: String, optionA: String, optionB: String, optionC: String, optionD: String, correctAnswer: String)]?

        do {
            let content = try String(contentsOfURL: contentsOfURL, encoding: encoding)
            items = []
            let lines: [String] = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]

            for line in lines {
                var values: [String] = []
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.rangeOfString("\"") != nil {
                        var textToScan: String = line
                        var value: NSString?
                        var textScanner: NSScanner = NSScanner(string: textToScan)
                        while textScanner.string != "" {

                            if (textScanner.string as NSString).substringToIndex(1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpToString("\"", intoString: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpToString(delimiter, intoString: &value)
                            }

                            // Store the value into the values array

                            values.append(value as! String)

                            // Retrieve the unscanned remainder of the string
                            if textScanner.scanLocation < textScanner.string.characters.count {
                                textToScan = (textScanner.string as NSString).substringFromIndex(textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = NSScanner(string: textToScan)
                        }

                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                    } else {
                        values = line.componentsSeparatedByString(delimiter)
                    }
                    // Put the values into the tuple and add it to the items array
                    let item = (question: values[0], type: values[1], optionA: values[2], optionB: values[3], optionC: values[4], optionD: values[5], correctAnswer: values[6])
                    items?.append(item)
                }
            }
        } catch let error1 as NSError {
            error = error1
        }
        if let value = items {
            return value
        }
        throw error
    }

    func preloadData() {
        // Retrieve data from the source file
        if let contentsOfURL = NSBundle.mainBundle().URLForResource("questionCSV", withExtension: "csv") {

            // Remove all the menu items before preloading
            removeData()


            do {
                let items = try parseCSV(contentsOfURL, encoding: NSUTF8StringEncoding)
                // Preload the menu items

                    for item in items {
                        guard let questionItem = NSEntityDescription.insertNewObjectForEntityForName("Questions", inManagedObjectContext: coreDataStack.managedObjectContext) as? Questions else {
                            return
                        }
                        questionItem.question = item.question
                        questionItem.type = item.type
                        questionItem.optionA = item.optionA
                        questionItem.optionB = item.optionB
                        questionItem.optionC = item.optionC
                        questionItem.optionD = item.optionD
                        questionItem.correctAnswer = item.correctAnswer
                        coreDataStack.saveMainContext()
                }

            } catch let error1 as NSError {
                let alertController = UIAlertController(title: "Default Style", message: "Error has Occur. \(error1)", preferredStyle: .Alert)

                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    // ...
                }
                alertController.addAction(cancelAction)

                let oKAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(oKAction)                                // Present the AlertController
               UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    func removeData () {
        // Remove the existing items

            let fetchRequest = NSFetchRequest(entityName: "Questions")

            do{
                guard let questionItems = (try! coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Questions] else {
                    return
                }

                for question in questionItems {
                    coreDataStack.managedObjectContext.deleteObject(question)
                }

                try coreDataStack.managedObjectContext.save()

            }
            catch{
                let alertController = UIAlertController(title: "Default Style", message: "Error has Occur.", preferredStyle: .Alert)

                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    // ...
                }
                alertController.addAction(cancelAction)

                let oKAction = UIAlertAction(title: "Ok", style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(oKAction)
                // Present the AlertController
                UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)

            }



    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        NSNotificationCenter.defaultCenter().postNotificationName("alarmGoesToBackground", object: nil)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        application.cancelAllLocalNotifications()
        coreDataStack.saveMainContext()
    }




}
