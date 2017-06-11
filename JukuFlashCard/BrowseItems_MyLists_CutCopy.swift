//
//  BrowseItems_MyLists_CutCopy.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit


/**
 Displays a list of other WordLists that the current selected group of words can be moved or copied to.
 */
class BrowseItems_MyLists_CutCopy: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var moveButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var txtCancelButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var txtOKButton: UIButton!
    
    var avgheight : CGFloat = 0.0
    var selectedRows : [Int : Int]!;
    var multiselectList = [MyListEntry]();
    var currentmylist : MyListEntry!;
    
    var colorlistsPrefs : [String]!;
    var moveselected = false;
    var tableviewheight : CGFloat!;
    var delegate : CutCopyReloadDataDelegate!;
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds)
    var buttonheight : CGFloat!;
    
    /* Colors of "Copy" and "Move" buttons toggle back and forth. When one is pressed, the other's
     colors become muted/darker, and visa versa. */
    let primarydark : UIColor = UIColor(hex: 0xb3b3b3); //UIColor(hex: 0x1976D2);
    let textdark : UIColor = UIColor(hex: 0xFFFFFF);
    let primary : UIColor = UIColor(hex: 0x2196F3);
    let white : UIColor = UIColor(hex: 0xffffff);
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setAnchors();
        
        //Set up the CopyButton initially
        moveselected = false;
        toggleCutCopyButton(copyButton,turnOff: moveButton);
        
        // Create an array of available word lists that can be copied/moved to
        if SQLiteDataStore.sharedInstance.myDatabase.open() {
            
            SQLiteDataStore.attachInternalxDB()
            
            if(selectedRows != nil) {
                var releventids = "";
                var totalidcount = 0;
                for value in selectedRows.values {
                    if(totalidcount>0) {
                        releventids.appendContentsOf(",");
                    }
                    releventids.appendContentsOf(String(value));
                    totalidcount = totalidcount  + 1;
                }
                
                
                let sqlqueryMyListNamesCounts = String(sep:", ",
                                                       "SELECT [AllLists].Name ",
                                                       ", [AllLists].Sys ",
                                                       "FROM ",
                                                       "( ",
                                                       "SELECT [Name] ",
                                                       ",0 as [Sys] ",
                                                       "From JFavoritesLists ",
                                                       "Union ",
                                                       "SELECT 'Blue' as [Name], 1 as [Sys] ",
                                                       "Union ",
                                                       "SELECT 'Red' as [Name],1 as [Sys] ",
                                                       "Union ",
                                                       "SELECT 'Green' as [Name],1 as [Sys] ",
                                                       "Union ",
                                                       "SELECT 'Yellow' as [Name],1 as [Sys] ",
                                                       ") as AllLists ",
                                                       
                                                       //Note: the line below essentially just removes the current mylist from the list of available options to copy/move to
                    " WHERE (CASE WHEN AllLists.[Name] = '\(currentmylist.name)' and AllLists.[Sys] = \(currentmylist.sys) THEN 1 else 0 END) = 0 ",
                    "ORDER BY Sys desc"
                    
                );
                
                
                
                let results:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery(sqlqueryMyListNamesCounts,withArgumentsInArray: nil)
                
                if (results != nil) {
                    while (results.next()) {
                        
                        print("NAME: \(results.stringForColumn("Name"))")
                        if(results.intForColumn("Sys")==0 || colorlistsPrefs.contains(results.stringForColumn("Name"))) {
                            let dataforthislist  = MyListEntry(name: results.stringForColumn("Name"), sys: Int(results.intForColumn("Sys")),checkedstatus: 0,idstoaddorremove: releventids)
                            multiselectList.append(dataforthislist)
                        }
                        
                    }
                    
                    print("mlist: \(multiselectList)")
                    results.close()
                    
                } else {
                    print("RESULTS NIL!");
                }
                
                SQLiteDataStore.sharedInstance.myDatabase.close()
            }
            
        }
        
        cutcopytableView.delegate = self
        cutcopytableView.dataSource = self
        cutcopytableView.tableFooterView = UIView()
        
        if(tableviewheight != nil && tableviewheight>0) {
            cutcopytableView.heightAnchor.constraintEqualToConstant(tableviewheight).active = true;
        }
        
        
        if(multiselectList.count == 0 ) {
            let norecordsLabel = UILabel(frame: CGRectMake(0,0,300 * goldenRatio, 50 * goldenRatio));
            norecordsLabel.font = UIFont.italicSystemFontOfSize(18.0 * goldenRatio);
            norecordsLabel.text = "No Lists to Cut/Copy to..."
            
            self.cutcopytableView.addSubview(norecordsLabel)
            self.cutcopytableView.bringSubviewToFront(norecordsLabel)
            NSLayoutConstraint(item: norecordsLabel, attribute: .CenterY , relatedBy: .Equal, toItem: self.cutcopytableView, attribute: .CenterY, multiplier: 1, constant: 0).active = true;
            NSLayoutConstraint(item: norecordsLabel, attribute: .CenterX , relatedBy: .Equal, toItem: self.cutcopytableView, attribute: .CenterX, multiplier: 1, constant: 0).active = true;
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        // De-Selects all entries on start
        for i in 0 ..< multiselectList.count {
            multiselectList[i].checkedstatus = 0;
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return multiselectList.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ListNameCell", forIndexPath: indexPath) as! customTableViewCell_ListPopover
        let dataforthislist = multiselectList[indexPath.row];
        
        /** Show the list name */
        cell.listlabel.text = dataforthislist.name;
        
        cell.listlabel.font = cell.listlabel.font.fontWithSize(17.0 * goldenRatio)
        cell.starimage.hidden = true;
        
        /** IF its a system list */
        if(dataforthislist.sys ==  1) {
            cell.listlabel.text = "Favorites"
            cell.starimage.hidden = false;
            cell.starimage.setImage(UIImage(named: "ic_star_black")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            cell.starimage.tintColor = UIColor.blackColor()
            
            switch dataforthislist.name {
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
            
        }
        cell.checkbox.alpha = 1.0;
        cell.listlabel.alpha = 1.0;
        switch dataforthislist.checkedstatus {
        case 0:
            cell.checkbox.setImage(UIImage(named: "ic_check_box_outline_blank")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            
        case 1:
            cell.checkbox.setImage(UIImage(named: "ic_check_box")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            
        default:
            break;
        }
        
        
        //Adjust sizes based on devices size using the goldenRatio
        cell.listlabel.font = cell.listlabel.font.fontWithSize(17.0 * goldenRatio)
        
        if(buttonheight == nil) {
            buttonheight = 24.0 * goldenRatio;
        }
        
        cell.checkbox.userInteractionEnabled = false;
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected \(indexPath.row)")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ListNameCell", forIndexPath: indexPath) as! customTableViewCell_ListPopover
        
        
        let dataforthislist = multiselectList[indexPath.row];
        print("dataforthislist: \(dataforthislist)");
        cell.checkbox.alpha = 1.0
        cell.listlabel.alpha = 1.0
        
        if(dataforthislist.checkedstatus == 0) {
            multiselectList[indexPath.row].checkedstatus = 1;
            cell.checkbox.setImage(UIImage(named: "ic_check_box")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            
        } else {
            
            multiselectList[indexPath.row].checkedstatus = 0;
            cell.checkbox.setImage(UIImage(named: "ic_check_box_outline_blank")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        
        cutcopytableView.reloadData();
        
    }
    
    
    
    @IBAction func moveButtonPressed(sender: UIButton) {
        moveselected = true;
        toggleCutCopyButton(moveButton,turnOff: copyButton);
        
    }
    
    @IBAction func copyButtonPressed(sender: UIButton) {
        
        moveselected = false;
        toggleCutCopyButton(copyButton,turnOff: moveButton);
    }
    
    @IBOutlet weak var cutcopytableView: UITableView!
    
    @IBAction func okbutton(sender: UIButton) {
        
        
        if(multiselectList.count > 0){
            
            //Copy
            for myListEntry in multiselectList {
                SQLiteDataStore.insertWordsIntoFavorites(myListEntry)
            }
            
            if(moveselected) {
                
                //Move
                SQLiteDataStore.deleteWordsFromFavorites(currentmylist)
                delegate.removeidsandreload(selectedRows)
            }
            
        }
        
        delegate.cancelPressed();
        delegate.reloadMainMyListController();
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func cancelbutton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
     Colors of "Copy" and "Move" buttons toggle back and forth when one of the buttons is pressed. When one button is "activated", the other's
     colors become muted/darker, and visa versa.
     
     - parameter turnOn: UIButton that will be "activated" (i.e. highlighted)
     - parameter turnOff: UIButton that will be "deactivated" (i.e. dimmed)
     */
    private func toggleCutCopyButton(turnOn : UIButton, turnOff: UIButton) {
        
        turnOn.backgroundColor = primary;
        turnOn.alpha = 1.0;
        turnOn.titleLabel?.textColor = white;
        turnOn.titleLabel?.alpha = 1.0
        
        turnOff.backgroundColor = primarydark;
        turnOff.alpha = 0.8;
        turnOff.titleLabel?.textColor = textdark;
        turnOff.titleLabel?.alpha = 0.9
        
    }
    
    /**
     Adjusts anchors and font sizes so that they adhere to the "goldenRatio" parameter (based on device size). Keeps formatting
     constant as screen size increases/decreases
     */
    private func setAnchors() {
        headerView.heightAnchor.constraintEqualToConstant(50 * goldenRatio).active = true;
        copyButton.titleLabel!.font = txtCancelButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        moveButton.titleLabel!.font = txtCancelButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtCancelButton.titleLabel!.font = txtCancelButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtOKButton.titleLabel!.font = txtOKButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtOKButton.trailingAnchor.constraintEqualToAnchor(txtOKButton.superview?.trailingAnchor, constant: -(20 * goldenRatio)).active = true;
        txtCancelButton.trailingAnchor.constraintEqualToAnchor(txtCancelButton.superview?.trailingAnchor, constant:-(50.0 * goldenRatio + txtOKButton.frame.size.width)).active = true;
        cutcopytableView.bottomAnchor.constraintEqualToAnchor(cutcopytableView.superview?.bottomAnchor, constant: -50*goldenRatio).active = true;
    }
    
    
}

