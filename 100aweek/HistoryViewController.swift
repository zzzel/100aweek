//
//  HistoryViewController.swift
//  100aweek
//
//  Created by Zel Marko on 19/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HeaderCellDelegate, TimerRefreshDelegate {
    
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var toMainButton: UIButton!
    
    var sectionInfoArray = [SectionInfo]()
    var todaily: ViewController?
//    let dailyTransitionManager = DailyCustomTransition()
    let helper = TimeHelperClass()
    var selectedCell = TimingViewCell()
    
    // MARK: - Setup
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        historyTable.contentInset = UIEdgeInsetsMake(70, 0, 0, 0)
        
        if let vc = todaily {
            vc.delegate = self
        }
        
        if sectionInfoArray.count == 0 || sectionInfoArray.count != self.numberOfSectionsInTableView(historyTable) {
            let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let helper = TimeHelperClass()
            
            let fetchRequest = NSFetchRequest(entityName: "TimeEntry")
            do {
                let fetchResults = try! managedObjectContext?.executeFetchRequest(fetchRequest) as? [TimeEntry]
                
                var fetched = fetchResults!
                
                var weeks = [String]()
                var startDates = [String]()
                for entry in fetched {
                    let date = entry.startDate
                    let dateFormat = NSDateFormatter()
                    dateFormat.dateFormat = "d MMM yy"
                    let str = dateFormat.stringFromDate(date)
                    startDates.append(str)
                    let weekOfYear = helper.getWeekOfYear(date)
                    
                    weeks.append(weekOfYear)
                }
                weeks = helper.removeDuplicateElements(weeks)
                weeks.sortInPlace( { Int($0) > Int($1) } )
                
                var merge = [String]()
                var last = ""
                for date in startDates {
                    if date == last {
                        merge.append(date)
                    }
                    last = date
                }
                merge = helper.removeDuplicateElements(merge)
                
                var allDuplicates = [[TimeEntry]]()
                for duplicate in merge {
                    
                    var duplicates = [TimeEntry]()
                    var cou = fetched.count
                    
                    for var index = 0; index < cou; index++  {
                        let entry = fetched[index]
                        let date = entry.startDate
                        let dateFormat = NSDateFormatter()
                        dateFormat.dateFormat = "d MMM yy"
                        let str = dateFormat.stringFromDate(date)
                        
                        if str == duplicate {
                            duplicates.append(entry)
                            fetched.removeAtIndex(index--)
                            cou--
                        }
                    }
                    if duplicates.count > 0 {
                        allDuplicates.append(duplicates)
                    }
                }
                
                var mergedEntries = helper.mergeDaysMechanism(allDuplicates) + fetched
                mergedEntries.sortInPlace( { $0.startDate.compare($1.startDate) == NSComparisonResult.OrderedAscending })
                
                for weekNumber in weeks {
                    let sectionInfo = SectionInfo()
                    sectionInfo.isOpen = false
                    
                    for entry in mergedEntries {
                        let weekNum = helper.getWeekOfYear(entry.startDate)
                        if weekNum == weekNumber {
                            sectionInfo.timings.append(entry)
                        }
                    }
                    sectionInfoArray.append(sectionInfo)
                }
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - TableView Stuff
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionInfoArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = sectionInfoArray[section]
        
        return sectionInfo.isOpen ? 1 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)as! TimingViewCell
        let colorView = UIView()
        colorView.backgroundColor = UIColor.whiteColor()
        cell.selectedBackgroundView = colorView
        
        let sectionInfo = sectionInfoArray[indexPath.section]
        let times = helper.getSummedTimes(sectionInfo.timings)
        
        cell.activeLabel.text = times[0]
        cell.pausedLabel.text = times[1]
        cell.pausesLabel.text = times[2]
        
        let forRate = times[0].componentsSeparatedByString(" : ")
        cell.rateLabel.text = "\(forRate[0]) %"
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier("Header") as! HeaderViewCell
        header.frame = CGRect(x: header.frame.origin.x, y: header.frame.origin.y, width: historyTable.frame.width, height: header.frame.height)
        header.delegate = self
        
        let sectionInfo = sectionInfoArray[section]
        sectionInfo.headerCell = header
        
        header.weekLabel.text = sectionInfo.getStartEndOFWeek(sectionInfo.timings[0].startDate)
        header.ratingLabel.text = sectionInfo.getSuccessfullTimings(sectionInfo.timings)
        header.section = section
        
        let view = UIView(frame: header.frame)
        view.addSubview(header)
        header.visibleView = view
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func openSection(sectionHeaderCell: HeaderViewCell, section: Int) {
        let sectionInfo = sectionInfoArray[section]
        sectionInfo.isOpen = true
        
        var indexPathsToInsert = [NSIndexPath]()
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        indexPathsToInsert.append(indexPath)
       
        historyTable.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: .Top)
    }
    
    func closeSection(sectionHeaderCell: HeaderViewCell, section: Int) {
        let sectionInfo = sectionInfoArray[section]
        sectionInfo.isOpen = false
        
        var indexPathsToDelete = [NSIndexPath]()
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        indexPathsToDelete.append(indexPath)
        
        historyTable.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: .Top)
    }

    // MARK: - Actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? TimingViewCell {
            selectedCell = cell
            let index = historyTable.indexPathForCell(cell)

            let sectionInfo = sectionInfoArray[index!.section]
                    
            let daily = segue.destinationViewController as! DailyTableViewController
            daily.weekInfo = sectionInfo
            daily.todaily = todaily
            todaily?.delegate = nil
//            daily.transitioningDelegate = dailyTransitionManager
        }
    }
    
    @IBAction func unwindToWeekly(segue: UIStoryboardSegue) {
    }
    
    // MARK: - TimerRefreshDelegate
    
    func refreshLabel(time: String) {
        timerLabel.text = time
    }
}
