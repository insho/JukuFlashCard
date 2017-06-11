//
//  ListController_DropDown.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit

//Popover allowing user to add/remove a word from multiple favorite lists
class MyListChooserPopover: UITableViewController {
    
    var mDelegate: MyListChooserPopoverDelegate?
    var mDataSet : [MyListEntry]!;
    var mWordEntry : WordEntry!;
    var avgheight : CGFloat = 0.0
    var rowIndexPath : NSIndexPath!;
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds)
    var buttonheight : CGFloat!;
    var constraint_collection = [NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ListNameCell", forIndexPath: indexPath) as! customTableViewCell_ListPopover
        
        for constraint in cell.constraints {
            if(constraint.identifier == "starwidth" || constraint.identifier == "leadmargin") {
                constraint.active = false;
                cell.removeConstraint(constraint);
            }
        }
        
        
        
        cell.listlabel.text = mDataSet[indexPath.row].name
        
        
        if(mDataSet[indexPath.row].sys == 1 ) {
            /** Show the star and color it accordingly */
            cell.starimage.hidden = false;
            cell.starimage.setImage(UIImage(named: "ic_star_black")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            cell.starimage.tintColor = UIColor.blackColor()
            
            switch mDataSet[indexPath.row].name {
            case "Red":
                cell.starimage.tintColor = UIColor.redColor()
            case "Yellow":
                cell.starimage.tintColor = UIColor.yellowColor()
            case "Blue":
                cell.starimage.tintColor = UIColor.blueColor()
            case "Green":
                cell.starimage.tintColor = UIColor.greenColor()
            default:
                break;
                
            }
            
            cell.starimage.translatesAutoresizingMaskIntoConstraints = false;
            cell.starimage.frame = CGRectMake(0, 0, 22 * goldenRatio, 22 * goldenRatio)
            cell.starimage.widthAnchor.constraintEqualToConstant(22 * goldenRatio).active = true;
            cell.starimage.heightAnchor.constraintEqualToConstant(22 * goldenRatio).active = true;
            
        } else {
            
            // Hide the star
            cell.starimage.hidden = true;
            cell.starimage.setImage(UIImage(named: "ic_star_black")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            cell.starimage.tintColor = UIColor.blackColor()
        }
        
        
        /// If the word is already saved to this list, check the box
        if(mDataSet[indexPath.row].checkedstatus>=1) {
            cell.checkbox.setImage(UIImage(named: "ic_check_box")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        } else {
            cell.checkbox.setImage(UIImage(named: "ic_check_box_outline_blank")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            
        }
        
        //Adjust sizes based on devices size using the goldenRatio
        cell.listlabel.font = cell.listlabel.font.fontWithSize(17.0 * goldenRatio)
        cell.checkbox.translatesAutoresizingMaskIntoConstraints = false;
        cell.checkbox.frame = CGRectMake(0, 0, 22 * goldenRatio, 22 * goldenRatio)
        cell.checkbox.widthAnchor.constraintEqualToConstant(22 * goldenRatio).active = true;
        cell.checkbox.heightAnchor.constraintEqualToConstant(22 * goldenRatio).active = true;
        NSLayoutConstraint(item: cell.listlabel, attribute: .CenterY, relatedBy: .Equal, toItem: cell, attribute: .CenterY, multiplier: 1, constant: 0).active = true;
        cell.checkbox.userInteractionEnabled = false;
        cell.starimage.userInteractionEnabled = false;
        
        return cell
        
        
        
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ListNameCell", forIndexPath: indexPath) as! customTableViewCell_ListPopover
        
        
        print("row selected, current checked status: \(mDataSet[indexPath.row].checkedstatus )");
        
        // If the box was previously unchecked, and has just been checked
        if(mDataSet[indexPath.row].checkedstatus == 0) {
            
            
            // Add the word entry to the favorite list table in the db
            if(SQLiteDataStore.insertWordsIntoFavorites(mDataSet[indexPath.row])) {
                cell.checkbox.setImage(UIImage(named: "ic_check_box")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                mDataSet[indexPath.row].checkedstatus = 1;
                
                // Update the word entry favorites to include the new ist
                if(mDataSet[indexPath.row].sys==1
                    && !mWordEntry.favoriteLists.systemlists.contains(mDataSet[indexPath.row].name)) {
                    mWordEntry.favoriteLists.systemlists.append(mDataSet[indexPath.row].name);
                } else if(mDataSet[indexPath.row].sys==0
                    && !mWordEntry.favoriteLists.otherlists.contains(mDataSet[indexPath.row].name)) {
                    mWordEntry.favoriteLists.otherlists.append(mDataSet[indexPath.row].name);
                }
            }
            
            
            // If we are unchecking a previously checked list
        } else if (mDataSet[indexPath.row].checkedstatus == 1){
            
            
            
            // Remove the word entry from the favorite list table in the db
            if(SQLiteDataStore.deleteWordsFromFavorites(mDataSet[indexPath.row])) {
                cell.checkbox.setImage(UIImage(named: "ic_check_box_outline_blank")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                mDataSet[indexPath.row].checkedstatus = 0;
                
                // Update the word entry favorites to include the new ist
                if(mDataSet[indexPath.row].sys==1) {
                    let currentindex = mWordEntry.favoriteLists.systemlists.indexOf(mDataSet[indexPath.row].name)
                    mWordEntry.favoriteLists.systemlists.removeAtIndex(currentindex!);
                } else if(mDataSet[indexPath.row].sys==0){
                    let currentindex = mWordEntry.favoriteLists.otherlists.indexOf(mDataSet[indexPath.row].name)
                    mWordEntry.favoriteLists.otherlists.removeAtIndex(currentindex!);
                }
            }
            
            print("UPDATED syslist: \(mWordEntry.favoriteLists.systemlists)")
            print("UPDATED otherlists: \(mWordEntry.favoriteLists.otherlists)")
            
        }
        
        //Return the updated star colorshash to the main VC
        mDelegate?.retrieveUpdatedFavoritesFromMyListChooser(mWordEntry.favoriteLists, rowIndexPath: rowIndexPath)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDataSet.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 26 * goldenRatio;
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func viewDidDisappear(animated: Bool) {
        if(mDelegate != nil) {
            mDelegate?.dismissMyListChooserPopover();
        }
    }
    
}




