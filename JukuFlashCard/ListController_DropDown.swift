//
//  ListController_DropDown.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit

protocol ListController_DropDownSelectedDelegate: class
{
    func optionSelected(dropDownCategory: String, optionName: String)
}

//Dropdown in MenuPopover FlashCards, allowing user to choose different options for the flashcard VC
class ListController_DropDown: UITableViewController  {
    
    
    weak var mDelegate: ListController_DropDownSelectedDelegate?
    weak var initialdropdownarray: ListController_DropDownSelectedDelegate?
    
    var initialdropArray: [String]!
    var initialdropCategory: String!
    var idkey : Int!;
    var spinnertag: Int!;
    var goldenratio = setGoldenRatio(UIScreen.mainScreen().bounds);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.layer.cornerRadius = 3.0 * goldenratio
        self.view.layer.borderWidth = 0.5 * goldenratio
        self.view.layer.borderColor = UIColor.blackColor().CGColor
        
        // Add this
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return initialdropArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("customcell") as UITableViewCell? ?? UITableViewCell(style: .Default, reuseIdentifier: "customcell")
        cell.textLabel?.text = initialdropArray[indexPath.row]
        cell.textLabel?.font = cell.textLabel!.font.fontWithSize(18 * goldenratio)
        cell.textLabel?.adjustsFontSizeToFitWidth = true;
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        mDelegate?.optionSelected(initialdropCategory, optionName: initialdropArray[indexPath.row])
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 22 * goldenratio
    }
    
}
