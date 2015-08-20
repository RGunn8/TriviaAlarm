//
//  AlarmTableViewCell.swift
//  TrivaAlarm
//
//  Created by Ryan  Gunn on 7/22/15.
//  Copyright (c) 2015 Ryan  Gunn. All rights reserved.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {

    @IBOutlet var alarmSwitch: UISwitch!
    @IBOutlet var timeLabel: UILabel!

    @IBOutlet weak var alarmNameLabel: UILabel!

    func loadItem(time:NSDate, isOn:Bool){
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
       let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle

        timeLabel.text = formatter.stringFromDate(time)
        
       
        alarmSwitch.setOn(isOn, animated: true)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
