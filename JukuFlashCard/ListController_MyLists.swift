//
//  JLPTListController.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit




class ListController_MyLists: UITableViewController,UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, CreateAListDelegate, MenuPopoverFlashCardsDelegate {
    
    var databasePath = NSString()
    
    let mylistsubarray:Array = ["Browse/Edit","Flash Cards"];
    var mDataSet = [MyListEntry]()
    var availableWordLists : StarColorData = StarColorData();
    var expandedsection : Int!;
    var expandedheader : CollapsibleTableViewHeader_MyLists!;
    var goldenRatio : CGFloat!; // Mult ratio to get
    var colorlistsPrefs : [String] = ["Blue","Red"];
    var screenBounds : CGRect!;
    var navbardelegate_mainview : ContainerMainView_ChangeNavBarDelegate?
    var package: MenuPopoverToSeguePackage!;
    var showmylistheadercount : Bool! = false;
    var currentSelectedMyList : MyListEntry!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        screenBounds = UIScreen.mainScreen().bounds
        goldenRatio = setGoldenRatio(screenBounds);
        
        colorlistsPrefs = NSUserDefaults.standardUserDefaults().stringArrayForKey("favoritesstarsarray") as [String]!;
        showmylistheadercount = NSUserDefaults.standardUserDefaults().boolForKey("showmylistheadercount");
        
        tableView.registerClass(CollapsibleTableViewHeader_MyLists.self, forHeaderFooterViewReuseIdentifier: "cellheader")
        
        //INSTALL A NOTIFICATION SO this VC will recieve acknowledgment when the star is pressed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ListController_MyLists.reloadtableselector), name: "updatemylistcontroller", object: nil)
        
        pulldata();
        
    }
    override func viewWillAppear(animated: Bool) {
        
        
        let screenBounds = UIScreen.mainScreen().bounds
        dispatch_async(dispatch_get_main_queue(),
                       {
                        self.tableView.contentInset = setTableInset(screenBounds.width, height: screenBounds.height, goldenRatio: self.goldenRatio, extrapoints: 6, extrasubtract: 0, bottominset: 0);
                        
        })
        
        
        self.reloadtableselector();
        
        if(expandedsection != nil && mDataSet[expandedsection].wordCount>0) {
            mDataSet[expandedsection].collapsed = false;
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as? CollapsibleTableViewHeader_MyLists ?? CollapsibleTableViewHeader_MyLists(reuseIdentifier: "cellheader")
            header.setCollapsed(false);
            
        }
        
    }
    
    
    //Changes table inset based on orientation
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        let lengths = lengthsizes();
        
        let triggerTime = (Int64(NSEC_PER_MSEC) * 200)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            
            if(toInterfaceOrientation.isLandscape) {
                self.tableView.contentInset = setTableInset(lengths.1, height: lengths.0, goldenRatio: self.goldenRatio, extrapoints: 6, extrasubtract: 0, bottominset: 0);
            } else {
                self.tableView.contentInset = setTableInset(lengths.0, height: lengths.1, goldenRatio: self.goldenRatio, extrapoints: 6, extrasubtract: 0, bottominset: 0);
            }
        })
        
    }
    
    
    
    /**
     On long press of a WordList Header, this displays an options menu allowing
     user to clear a list, or (if it is a user-created list) Rename/Remove a list
     */
    func showmenu(longPressGesture:CustomLongPressRecognizer) {
        
        
        let indexPath = longPressGesture.index;
        
        let section = mDataSet[indexPath]
        if indexPath == nil {
            
        } else if (longPressGesture.state == UIGestureRecognizerState.Began) {
            print("Long press on row, at \(indexPath)")
            
            var listoptions = [String]();
            
            if(section.sys == 1) {
                
                //Only show the CLEAR option
                listoptions.append("1. Clear List")
                
            } else if (section.name != "Create a New List" || section.items.count != 0) {
                
                //If the user long presses the "Create a New List" row, no popup should appear
                
                //SHOW CLEAR, RENAME and REMOVE
                listoptions.append("1. Clear List")
                listoptions.append("2. Rename List")
                listoptions.append("3. Remove List")
            }
            
            if(listoptions.count > 0 && self.presentedViewController == nil) {
                let listoptions_popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("listoptionspopover") as! ListOptionsPopover
                listoptions_popController.modalPresentationStyle = UIModalPresentationStyle.Popover
                listoptions_popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
                listoptions_popController.popoverPresentationController?.sourceView = self.view
                listoptions_popController.popoverPresentationController?.delegate = self
                listoptions_popController.preferredContentSize = CGSizeMake(330*goldenRatio,230*goldenRatio);
                listoptions_popController.popoverPresentationController?.sourceRect = CGRectMake(CGFloat(CGRectGetMidX(self.tableView.bounds)), CGFloat(CGRectGetMidY(self.tableView.bounds)),0,0)
                listoptions_popController.delegate = self
                listoptions_popController.listoptions = listoptions;
                listoptions_popController.listname = section.name
                listoptions_popController.listsys = section.sys
                
                self.presentViewController(listoptions_popController, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
    /* Create a list of MyListEntry objects for each MyList (both system and user-created). Also appened
     a "Create a New List" row that acts like a button, bringing up a create new list menu */
    func pulldata(){
        
        mDataSet = [MyListEntry]()
        
        if SQLiteDataStore.sharedInstance.myDatabase.open() {
            
            SQLiteDataStore.attachInternalxDB()
            
            let sqlqueryMyLists = String(sep:", ",
                                         "SELECT xx.[Name] ",
                                         ",xx.[Sys] ",
                                         ",ifnull(yy.[WordCount],0) as [WordCount] ",
                                         ",[Order] ",
                                         "FROM ",
                                         "( ",
                                         "SELECT [Name] ",
                                         ",0 as [Sys] ",
                                         ",4 as [Order] ",
                                         "From JFavoritesLists ",
                                         "Union ",
                                         "SELECT 'Blue' as [Name], 1 as [Sys], 1 as [Order] ",
                                         "Union ",
                                         "SELECT 'Red' as [Name],1 as [Sys], 2 as [Order]  ",
                                         "Union ",
                                         "SELECT 'Green' as [Name],1 as [Sys], 3 as [Order]  ",
                                         "Union ",
                                         "SELECT 'Yellow' as [Name],1 as [Sys], 4 as [Order]  ",
                                         ") as [xx] ",
                                         "LEFT JOIN ",
                                         "( ",
                                         "SELECT  DISTINCT [Name] ",
                                         ",[Sys] ",
                                         ",count([_id]) as [WordCount] ",
                                         "FROM JFavorites ",
                                         "GROUP BY [Name],[Sys] ",
                                         ") as yy ",
                                         "ON xx.[Name] = yy.[Name] and xx.[sys] = yy.[sys] ",
                                         "Order by xx.[Sys] Desc,xx.[Order]");
            
            let results:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery(sqlqueryMyLists,
                                                                                              withArgumentsInArray: nil)
            var i = 0;
            var foundanexpandablesection = false;
            var initialcollapsed = true;
            
            if(expandedsection != nil) {
                foundanexpandablesection = true;
            }
            
            
            if (results != nil) {
                while (results.next()) {
                    initialcollapsed = true;
                    
                    if(Int(results.intForColumn("Sys")) == 1 && !colorlistsPrefs.contains(results.stringForColumn("Name")) ){
                        //Ignore system lists that are not included in the user preferences
                    } else {
                        if(foundanexpandablesection == false) {
                            
                            if( Int(results.intForColumn("WordCount")) > 0) {
                                initialcollapsed = false
                                
                                print("TT Initial expanded section: \(i)")
                                expandedsection = i;
                                foundanexpandablesection = true;
                            }
                        }
                        
                        
                        mDataSet.append(
                            MyListEntry(name: results.stringForColumn("Name")
                                , sys: Int(results.intForColumn("Sys"))
                                , items: mylistsubarray
                                ,collapsed:initialcollapsed
                                ,wordCount:Int(results.intForColumn("WordCount"))
                            )
                        )
                        
                        
                        /* Compiles the "availableWordLists" star colors data object, splitting
                         Favorites lists into seperate arrays, one for "system" lists and another for User-Created lists */
                        if(Int(results.intForColumn("Sys")) == 1) {
                            availableWordLists.systemlists.append(results.stringForColumn("Name"))
                        } else {
                            availableWordLists.otherlists.append(results.stringForColumn("Name"))
                        }
                        
                        i =  i + 1;
                        
                    }
                    
                    
                }
            }
            
            //Append a line for the Create a new List
            mDataSet.append(
                MyListEntry(name: "Create a New List"
                    , sys: -1
                    , items: [String]()
                    ,collapsed:true
                    ,wordCount: 0
                )
            )
            
            
            
            
            SQLiteDataStore.sharedInstance.myDatabase.close()
        } else {
            print("Error3: \(SQLiteDataStore.sharedInstance.myDatabase.lastErrorMessage())")
        }
        
        
    }
    
    
    
}

extension ListController_MyLists {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mDataSet.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDataSet[section].items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell();
        cell.layoutMargins = UIEdgeInsetsMake(0, 24 * goldenRatio, 0, 24 * goldenRatio);
        cell.textLabel!.text = mDataSet[indexPath.section].items[indexPath.row]
        cell.textLabel!.font = cell.textLabel!.font.fontWithSize(16 * goldenRatio)
        cell.selectionStyle = .None
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return mDataSet[indexPath.section].collapsed! ? 0 : 44.0 * goldenRatio
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as? CollapsibleTableViewHeader_MyLists ?? CollapsibleTableViewHeader_MyLists(reuseIdentifier: "header")
        
        
        let header = CollapsibleTableViewHeader_MyLists();
        
        header.emptylabel.hidden = true;
        header.emptylabel.font = header.emptylabel.font.fontWithSize(13.0 * goldenRatio)
        
        header.titleLabel_Plain.textColor = UIColor.blackColor();
        header.titleLabel.textColor = UIColor.blackColor();
        header.emptylabel.textColor = UIColor.blackColor();
        
        
        // Add a star image next to the listname if it is a system list
        if(mDataSet[section].sys == 1) {
            header.titleLabel_CreateAList.hidden = true;
            header.titleLabel_Plain.hidden = true;
            header.titleLabel.hidden = false;
            
            header.titleLabel.text = "Favorites"
            header.titleLabel.font = UIFont.boldSystemFontOfSize(16.0 * goldenRatio)
            header.starbutton.setImage(UIImage(named: "ic_star_black")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            header.starbutton.hidden = false;
            
            switch mDataSet[section].name {
            case "Blue":
                header.starbutton.tintColor = UIColor.blueColor()
            case "Green":
                header.starbutton.tintColor = UIColor.greenColor()
            case "Red":
                header.starbutton.tintColor = UIColor.redColor()
            case "Yellow":
                header.starbutton.tintColor = UIColor.yellowColor()
            default:
                header.starbutton.tintColor = UIColor.blackColor()
                break;
            }
            
            
            let buttonheight = 24.0 * goldenRatio;
            header.starbutton.frame = CGRectMake(0,0,buttonheight,buttonheight)
            header.starbutton.widthAnchor.constraintEqualToConstant(buttonheight).active = true;
            header.starbutton.heightAnchor.constraintEqualToConstant(buttonheight).active = true;
            
            header.starbutton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
            header.starbutton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
            
            
        } else if(mDataSet[section].name == "Create a New List" && mDataSet[section].items.count == 0) {
            header.tag = 1; //CREATE A NEW LST
            header.titleLabel_CreateAList.hidden = false;
            header.titleLabel_CreateAList.text = "Create a New List"
            
            header.emptylabel.hidden = true;
            header.titleLabel_Plain.hidden = true;
            header.starbutton.setImage(nil, forState: .Normal)
            header.starbutton.hidden = true;
            
            header.titleLabel.hidden = true;
            
        } else {
            
            header.titleLabel_CreateAList.hidden = true;
            header.titleLabel_Plain.hidden = false;
            header.titleLabel_Plain.text = mDataSet[section].name
            header.titleLabel_Plain.font = UIFont.boldSystemFontOfSize(18.0 * goldenRatio)
            header.starbutton.setImage(nil, forState: .Normal)
            header.starbutton.hidden = true;
            header.titleLabel.hidden = true;
            
        }
        
        
        if(showmylistheadercount != nil && showmylistheadercount == true) {
            header.emptylabel.hidden = false;
            
            if(mDataSet[section].name == "Create a New List" && mDataSet[section].items.count == 0) {
                header.emptylabel.text = "";
            } else if(mDataSet[section].wordCount <= 0) {
                header.emptylabel.text = " (empty)"
                
                
            } else {
                header.emptylabel.text = " (\(mDataSet[section].wordCount))"
            }
            
        }
        
        
        header.setCollapsed(mDataSet[section].collapsed)
        header.textLabel?.textColor = UIColor(hex: 0xffffff);
        header.section = section
        header.delegate = self
        
        let totalCount = mDataSet[section].wordCount;
        
        
        if(expandedsection != nil && expandedsection == section) {
            expandedheader = header;
        }
        
        
        
        //IF the list is empty, make the label grey
        if(mDataSet[section].name == "Create a New List" && mDataSet[section].items.count == 0) {
            header.tag = 1; //CREATE A NEW LST
            
        } else if(totalCount == nil || totalCount == 0){
            header.tag = 2; //An empty list
            
            header.titleLabel_Plain.textColor = UIColor.lightGrayColor();
            header.titleLabel.textColor = UIColor.lightGrayColor();
            header.emptylabel.textColor = UIColor.lightGrayColor();
            
        } else {
            header.tag = 0; //Regular ole' list
        }
        
        //Only add the edit list long-press recognizer to actual list items, not to the "Create a New List" button
        if(mDataSet[section].name != "Create a New List") {
            
            let longPressGesture = CustomLongPressRecognizer(target: self, action: #selector(showmenu(_:)), index: section);
            longPressGesture.delegate = self
            header.addGestureRecognizer(longPressGesture);
            
        }
        
        header.titleLabel.font = UIFont.boldSystemFontOfSize(18.0 * goldenRatio)
        header.titleLabel_CreateAList.font = UIFont.boldSystemFontOfSize(18.0 * goldenRatio)
        header.titleLabel_Plain.font = UIFont.boldSystemFontOfSize(18.0 * goldenRatio)
        
        headerCell.addSubview(header);
        return header;
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0 * goldenRatio
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if(mylistsubarray.count>=indexPath.row){
            
            let destination = mylistsubarray[indexPath.row]
            
            switch destination {
                
            case "Browse/Edit":
                
                self.currentSelectedMyList = mDataSet[indexPath.section];
                self.performSegueWithIdentifier("mylistbrowsesegue", sender: nil)
                
            case "Flash Cards":
                
                if(self.presentedViewController == nil) {
                    
                    /*Clicking flash cards opens an options menu, allowing user to select what will appear on the flashcards. Only after OK is pressed
                     in that menu will the actual FlashCard activity commence */
                    let popController_flashcards = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("menuPopover_FlashCards") as! MenuPopover_FlashCards
                    
                    popController_flashcards.modalPresentationStyle = UIModalPresentationStyle.Popover
                    popController_flashcards.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
                    popController_flashcards.popoverPresentationController?.sourceView = self.view
                    popController_flashcards.popoverPresentationController?.delegate = self
                    if(goldenRatio >= 1) {
                        popController_flashcards.preferredContentSize = CGSizeMake(340*goldenRatio,220*goldenRatio);
                        
                    } else {
                        popController_flashcards.preferredContentSize = CGSizeMake(340*goldenRatio,260*goldenRatio);
                        
                    }
                    popController_flashcards.popoverPresentationController?.sourceRect = CGRectMake(CGFloat(CGRectGetMidX(self.view.bounds)),CGFloat(CGRectGetMidY(self.view.bounds)),0,0)
                    
                    popController_flashcards.jlptdelegate = self
                    popController_flashcards.currentMyList = mDataSet[indexPath.section];
                    
                    self.presentViewController(popController_flashcards, animated: true, completion: nil)
                    
                }
                
                
            default:
                break;
            }
            
            
        } else {
            print("ERROR -- PATH ROW \(indexPath.row) is out of range of the list, or vice versa")
        }
        
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        switch segue.identifier {
            
        case "mylistbrowsesegue"?:
            let secondViewController = segue.destinationViewController as! BrowseItems_MyLists
            secondViewController.currentMyList = currentSelectedMyList;
            secondViewController.mylistrowcount = mDataSet.count - 1;
            secondViewController.availableWordLists = availableWordLists;
            
            secondViewController.navbardelegate_mainview = navbardelegate_mainview;
            
            navbardelegate_mainview?.changeNavBarButton_SetBackButton(currentSelectedMyList.name)
            
        case "mylists_segueto_flashcards"?:
            
            
            let secondViewController = segue.destinationViewController as! FlashCards
            
            secondViewController.currentMyList = package.currentMyList
            secondViewController.frontValue = package.frontvalue;
            secondViewController.backValue = package.backvalue;
            
            navbardelegate_mainview?.changeNavBarButton_SetBackButton(package.currentMyList.name)
            
        default:
            break;
        }
        
    }
}



extension ListController_MyLists: CollapsibleTableViewHeaderDelegate_MyLists {
    
    func toggleSection_MyLists(header: CollapsibleTableViewHeader_MyLists, section: Int) {
        
        //If its a create a new list cell do that
        if(header.tag == 1) {
            showCreateListPopover(false,oldname: "")
        } else if(header.tag == 2){
            header.emptylabel.hidden = false;
            
        } else {
            //Look for an already expanded section, close it if one exists
            if(expandedsection != nil && expandedsection != section) {
                
                mDataSet[expandedsection].collapsed = true
                expandedheader.setCollapsed(true)
                
                // Adjust the height of the rows inside the section
                tableView.beginUpdates()
                for i in 0 ..< mDataSet[expandedsection].items.count {
                    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: expandedsection)], withRowAnimation: .Automatic)
                }
                tableView.endUpdates()
                
            }
            
            // Toggle collapse
            let collapsed = !mDataSet[section].collapsed
            
            mDataSet[section].collapsed = collapsed
            header.setCollapsed(collapsed)
            
            // Adjust the height of the rows inside the section
            tableView.beginUpdates()
            for i in 0 ..< mDataSet[section].items.count {
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i, inSection: section)], withRowAnimation: .Automatic)
            }
            tableView.endUpdates()
            
            expandedsection = section;
            expandedheader = header;
        }
        
        
        
    }
    
    
    /**
     Popover with text edit allowing user to input a new list, or rename a current list
     
     - parameter renamelist: bool true if a current is being renamed, false if it is a new list
     - parameter oldname: name of list that will be renamed (if user is renaming a list)
     */
    func showCreateListPopover(renamelist: Bool, oldname: String) {
        
        
        if(self.presentedViewController == nil) {
            let popController_createalist = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("createalistpopover") as! CreateAListPopover
            popController_createalist.modalPresentationStyle = UIModalPresentationStyle.Popover
            popController_createalist.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
            popController_createalist.popoverPresentationController?.sourceView = self.view
            popController_createalist.popoverPresentationController?.delegate = self
            popController_createalist.preferredContentSize = CGSizeMake(330*goldenRatio,230*goldenRatio);
            popController_createalist.popoverPresentationController?.sourceRect = CGRectMake(CGFloat(CGRectGetMidX(self.tableView.bounds)), CGFloat(CGRectGetMidY(self.tableView.bounds)),0,0)
            popController_createalist.delegate = self
            popController_createalist.availableWordLists = availableWordLists;
            popController_createalist.renamelist = renamelist;
            popController_createalist.oldname = oldname;
            
            if(renamelist) {
                popController_createalist.header = "New Name for \(oldname)"
            } else {
                popController_createalist.header = "Create a List"
            }
            
            self.presentViewController(popController_createalist, animated: true, completion: nil)
        }
        
        
    }
    
    /**
     Called from ContainerMainView when an event has occured in Search or Preference fragment,
     updating the MyList data to reflect changes
     */
    func reloadtableselector(){
        updatemylisttable { (success) -> Void in
            if success {
                // do second task if success
                self.reloadtableview()
            }
        }
    }
    
    //Refreshes mylist table
    func updatemylisttable(completion: (success: Bool) -> Void) {
        colorlistsPrefs = NSUserDefaults.standardUserDefaults().stringArrayForKey("favoritesstarsarray") as [String]!;
        showmylistheadercount = NSUserDefaults.standardUserDefaults().boolForKey("showmylistheadercount");
        pulldata()
        completion(success: true)
    }
    
    func reloadtableview(){
        tableView.reloadData();
        tableView.tableHeaderView?.reloadInputViews()
    }
    
    
    
    
    /**
     Inserts a new listname into the JFavoritesLists table when user has added a list via the "Create a New List" menu
     
     -parameter newlistname: String name of new list to be inserted into the JFavoritesLists table
     */
    func createthenewlist(newlistname: String) {
        
        if SQLiteDataStore.sharedInstance.myDatabase.open() {
            
            SQLiteDataStore.attachInternalxDB()
            
            do {
                
                try SQLiteDataStore.sharedInstance.myDatabase.executeUpdate("INSERT OR REPLACE INTO JFavoritesLists SELECT ? as [Name]", values: [newlistname]);
                
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            
            SQLiteDataStore.sharedInstance.myDatabase.close()
            
            //update the tableview
            reloadtableselector();
        }
        
    }
    
    
    /**
     Removes or clears out words from a MyList when user chooses Clear or Delete from the Edit Lists menu
     
     - parameter name: list name
     - parameter sys: list system designation (1 for system list, 0 for user created list)
     - parameter delete: bool true to delete the user created list entirely, false to only clear out the words from the list
     */
    func clearordeletethelist(name: String, sys : Int, delete : Bool) {
        
        if SQLiteDataStore.sharedInstance.myDatabase.open() {
            
            SQLiteDataStore.attachInternalxDB()
            
            do {
                //Clear the mylist
                print("CLEARING name: \(name), sys: \(sys)")
                try SQLiteDataStore.sharedInstance.myDatabase.executeUpdate("DELETE from JFavorites where Name = ? and Sys = ?", values: [name,String(sys)]);
                //Clear the mylist progress
                try SQLiteDataStore.sharedInstance.myDatabase.executeUpdate("DELETE FROM JProgress WHERE Sys >= 0 and Name =? and Sys = ?", values: [name,String(sys)]);
                
                if(delete == true) {
                    try SQLiteDataStore.sharedInstance.myDatabase.executeUpdate("DELETE FROM JFavoritesLists WHERE Name =?", values: [name]);
                }
                
                
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            
            SQLiteDataStore.sharedInstance.myDatabase.close()
            
            reloadtableselector();
        }
        
        
        
    }
    
    
    
    /**
     Updates a list name when user has chosen to Rename List in the Edit List menu
     
     - parameter oldname: current list name associated with the user-created list
     - parameter newname: new name for the list
     */
    func renamethelist(oldname: String, newname : String) {
        
        if SQLiteDataStore.sharedInstance.myDatabase.open() {
            
            SQLiteDataStore.attachInternalxDB()
            
            do {
                try SQLiteDataStore.sharedInstance.myDatabase.executeUpdate("Update JFavoritesLists SET [Name]=? WHERE [Name]=? ", values: [newname,oldname]);
                try SQLiteDataStore.sharedInstance.myDatabase.executeUpdate("Update JFavorites SET [Name]=? WHERE [Name]=? and [Sys] = 0", values: [newname,oldname]);
                try SQLiteDataStore.sharedInstance.myDatabase.executeUpdate("Update JProgress SET [Name]=? WHERE Sys >= 0 and Name =?", values: [newname,oldname]);
                
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            
            SQLiteDataStore.sharedInstance.myDatabase.close()
            
            //update the tableview
            reloadtableselector();
        }
        
    }
    
    
    func seguetoactivity(package: MenuPopoverToSeguePackage) {
        if(self.presentedViewController != nil) {
            self.presentedViewController?.dismissViewControllerAnimated(false, completion: nil);
        }
        
        self.package = package;
        self.performSegueWithIdentifier("mylists_segueto_flashcards", sender: nil)
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection)  -> UIModalPresentationStyle {
        return .None
    }
}
