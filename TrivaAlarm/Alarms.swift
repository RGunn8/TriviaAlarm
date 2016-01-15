//
//  Alarms.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 12/26/15.
//  Copyright © 2015 Ryan  Gunn. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Alarms: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    func setNotfiicaitonsForOnAlarms () {
        let notification = UILocalNotification()

        notification.alertBody = "It Time, It Time to Wake Up and Be Great"
        notification.fireDate =  self.time
        notification.soundName = self.alertSound
        notification.timeZone = NSCalendar.currentCalendar().timeZone
        notification.repeatInterval = NSCalendarUnit.Minute
        notification.userInfo = userInfoForNotification()
        UIApplication.sharedApplication().scheduleLocalNotification(notification)

    }


    func secondNotificationForAlarms() {
        let notification2 = UILocalNotification()

        let notification2Date: NSDate = self.time.dateByAddingTimeInterval(30)
        notification2.alertBody = "It Time, It Time to Wake Up and Be Great"
        notification2.fireDate =  notification2Date
        notification2.soundName = self.alertSound
        notification2.timeZone = NSCalendar.currentCalendar().timeZone
        notification2.repeatInterval = NSCalendarUnit.Minute
        notification2.userInfo = userInfoForNotification()
        UIApplication.sharedApplication().scheduleLocalNotification(notification2)

    }

    func userInfoForNotification() -> [String: String] {
        var userInfo: [String: String] = [String: String]()
        let numOfQuestion = "\(self.numOfQuestionsToEnd)" as String
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.LongStyle
        let alarmDate = formatter.stringFromDate(self.time)
        userInfo["NumberOfQuestion"] = numOfQuestion ?? "1"

        userInfo["TypeOfQuestion"] = self.questionType ?? "Random"

        userInfo["AlarmDate"] = alarmDate ?? "nil"

        userInfo["AlarmSound"] = self.alertSound ?? "LoudAlarm.wav"
        return userInfo
        
    }

    func setAlarmDate() -> NSDate {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let nowComponents = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: now)
        let alarmComponents = calendar.components([.Year, .Day, .Hour, .Minute, .Month], fromDate: self.time)

        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = .MediumStyle

        var alarmDate: NSDate

        if calendar.isDate(self.time, inSameDayAsDate: now) {
            if calendar.isDate(now, equalToDate: self.time, toUnitGranularity: .Hour) {

                if alarmComponents.minute <= nowComponents.minute {

                    alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!
                } else {
                    alarmDate = calendar.dateFromComponents(alarmComponents)!

                }
            } else if alarmComponents.hour < nowComponents.hour {
                alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!

            }else {
                alarmDate = calendar.dateFromComponents(alarmComponents)!
            }
        } else {
            if alarmComponents.hour == nowComponents.hour {
                if alarmComponents.minute <= nowComponents.minute {
                    alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!
                }else {
                    alarmComponents.day = nowComponents.day
                    alarmDate = calendar.dateFromComponents(alarmComponents)!
                }
            }else if alarmComponents.hour < nowComponents.hour {

                alarmDate = calendar.nextDateAfterDate(now, matchingHour: alarmComponents.hour, minute: alarmComponents.minute, second: 0, options: .MatchNextTime)!


            }else {
                alarmComponents.day = nowComponents.day
                alarmDate = calendar.dateFromComponents(alarmComponents)!
            }
        }
        return alarmDate
        
    }

    func alarmInTheSameDay() -> Bool {
        let now = NSDate()
        let calendar = NSCalendar.currentCalendar()
        return calendar.isDate(self.time, inSameDayAsDate: now)

    }

    func turnOffAlarmNotification() {

        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]!
        for notificaion in notifications {
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.LongStyle
            formatter.timeStyle = NSDateFormatterStyle.LongStyle
            let alarmDate = formatter.stringFromDate(self.time)
            if let notifDate = notificaion.userInfo?["AlarmDate"] as? String {
                if alarmDate == notifDate {
            UIApplication.sharedApplication().cancelLocalNotification(notificaion)

                }
            }
        }
    }


}
