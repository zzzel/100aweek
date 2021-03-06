//
//  TimeEntry.swift
//  100aweek
//
//  Created by Zel Marko on 19/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import Foundation
import CoreData

class TimeEntry: NSManagedObject {

    @NSManaged var startDate: NSDate
    @NSManaged var activeTime: String
    @NSManaged var duration: String
    @NSManaged var endTime: String
    @NSManaged var pauseCount: NSNumber
    @NSManaged var pausedTime: String
    @NSManaged var startTime: String
    @NSManaged var summary: String?

    class func createInManagedObjectContext(moc: NSManagedObjectContext, _startDate: NSDate, _startTime: String, _endTime: String,  _activeTime: String, _pausedTime: String, _pauseCount: NSNumber, _summary: String) -> TimeEntry {
        
        let newEntry = NSEntityDescription.insertNewObjectForEntityForName("TimeEntry", inManagedObjectContext: moc) as! TimeEntry
        
        newEntry.startDate = _startDate
        newEntry.startTime = _startTime
        newEntry.endTime = _endTime
        //newEntry.duration = _duration
        newEntry.activeTime = _activeTime
        newEntry.pausedTime = _pausedTime
        newEntry.pauseCount = _pauseCount
        newEntry.summary = _summary
        
        return newEntry
    }
    
    class func createWithoutManagedObject(_startDate: NSDate, _startTime: String, _endTime: String, _activeTime: String, _pausedTime: String, _pauseCount: NSNumber, _summary: String) -> TimeEntry {
        
        
        let managedObjectContext = AppDelegate().managedObjectContext
        let entity = NSEntityDescription.entityForName("TimeEntry", inManagedObjectContext: managedObjectContext!)
        let newEntry = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: nil)as! TimeEntry
        
        newEntry.startDate = _startDate
        newEntry.startTime = _startTime
        newEntry.endTime = _endTime
        //newEntry.duration = _duration
        newEntry.activeTime = _activeTime
        newEntry.pausedTime = _pausedTime
        newEntry.pauseCount = _pauseCount
        newEntry.summary = _summary
        
        return newEntry
    }


}
