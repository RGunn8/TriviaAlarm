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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.cancelAllLocalNotifications()
       let defualts = NSUserDefaults.standardUserDefaults()
        defualts.setValue(22.5, forKey: "boss")

        UINavigationBar.appearance().barTintColor = UIColor(red: (49/255), green: (128/255), blue: (197/255), alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]


        let defaults = NSUserDefaults.standardUserDefaults()
        let isPreloaded = defaults.boolForKey("isPreloaded")
        if !isPreloaded {
            preloadData()
            defaults.setBool(true, forKey: "isPreloaded")
        }

        UINavigationBar.appearance().barStyle = .Black


       
//        let nc = NSNotificationCenter.defaultCenter()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil))

        if let options = launchOptions {

            if let notification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {


                      dispatch_async(dispatch_get_main_queue(), {


                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionVC") as! QuestionViewController
                        self.window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
                        // NSNotificationCenter.defaultCenter().postNotificationName("questionSegue", object: nil)
                        let numbOfQuestion:AnyObject = notification.userInfo!["NumberOfQuestion"]!
                        let typeOfQuestion:AnyObject = notification.userInfo!["TypeOfQuestion"]!
                        let alarmDate:AnyObject = notification.userInfo!["AlarmDate"]!
                        let alarmSound:AnyObject = notification.userInfo!["AlarmSound"]!
                        let nc = NSNotificationCenter.defaultCenter()
                        nc.postNotificationName("localNotficaionUserInfo", object: nil, userInfo: ["NumberOfQuestion":numbOfQuestion , "TypeOfQuestion": typeOfQuestion, "AlarmDate": alarmDate, "AlarmSound":alarmSound])
                        application.cancelLocalNotification(notification)

                })

                 application.cancelLocalNotification(notification)



            }
        }


        return true
    }
  
        func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
            application.cancelAllLocalNotifications()

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("QuestionVC") as! QuestionViewController
                self.window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
                // NSNotificationCenter.defaultCenter().postNotificationName("questionSegue", object: nil)
                let numbOfQuestion:AnyObject = notification.userInfo!["NumberOfQuestion"]!
                let typeOfQuestion:AnyObject = notification.userInfo!["TypeOfQuestion"]!
                let alarmDate:AnyObject = notification.userInfo!["AlarmDate"]!
            let alarmSound:AnyObject = notification.userInfo!["AlarmSound"]!
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName("localNotficaionUserInfo", object: nil, userInfo: ["NumberOfQuestion":numbOfQuestion , "TypeOfQuestion": typeOfQuestion, "AlarmDate": alarmDate, "AlarmSound":alarmSound])
                application.cancelLocalNotification(notification)








    }

    func parseCSV (contentsOfURL: NSURL, encoding: NSStringEncoding) throws -> [(question:String, type:String, optionA: String, optionB: String, optionC:String, optionD:String, correctAnswer:String)] {
        var error: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        // Load the CSV file and parse it
        let delimiter = ","
        var items:[(question:String, type:String, optionA: String, optionB: String, optionC:String, optionD:String, correctAnswer:String)]?

        do {
            let content = try String(contentsOfURL: contentsOfURL, encoding: encoding)
            items = []
            let lines:[String] = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]

            for line in lines {
                var values:[String] = []
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.rangeOfString("\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:NSScanner = NSScanner(string: textToScan)
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
                    } else  {
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

    

    func preloadData () {
        // Retrieve data from the source file
        if let contentsOfURL = NSBundle.mainBundle().URLForResource("questionCSV", withExtension: "csv") {

            // Remove all the menu items before preloading
            removeData()


            do {
                let items = try parseCSV(contentsOfURL, encoding: NSUTF8StringEncoding)
                // Preload the menu items
                if let managedObjectContext = self.managedObjectContext {
                    for item in items {
                        let questionItem = NSEntityDescription.insertNewObjectForEntityForName("Questions", inManagedObjectContext: managedObjectContext) as! Questions
                        questionItem.question = item.question
                        questionItem.type = item.type
                        questionItem.optionA = item.optionA
                        questionItem.optionB = item.optionB
                        questionItem.optionC = item.optionC
                        questionItem.optionD = item.optionD
                        questionItem.correctAnswer = item.correctAnswer

                        try self.managedObjectContext!.save()

                    
                }
                }
            } catch let error1 as NSError {
               print("\(error1)")
            }
        }
    }

    func removeData () {
        // Remove the existing items
        if let managedObjectContext = self.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Questions")

            do{
            let questionItems = (try! managedObjectContext.executeFetchRequest(fetchRequest)) as! [Questions]

                for question in questionItems {
                    managedObjectContext.deleteObject(question)
                }

                try self.managedObjectContext!.save()

            }
            catch{
                print(error)
            }


        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Ryan-Gunn.TrivaAlarm" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("TrivaAlarm", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("TrivaAlarm.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

}

