//
//  BrowseItems_MyLists.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//


import UIKit


//User can browse a list of words in a given MyList, and make edits to the list by selecting rows and using cut/copy navbar buttons
class BrowseItems_MyLists: UITableViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, TrashPressedUndoDelegate, CutCopyReloadDataDelegate {
    
    
    let interactor = Interactor()
    
    var displaywidth : Int!;
    var displayheight : Int!;
    var currentMyList : MyListEntry!;
    var mDataSet : [WordEntry]!;
    var availableWordLists : StarColorData!;
    var mylistrowcount : Int = 0;
    
    var selectedRows = [Int : Int](); // [Row : PKey], tracks selected rows for favorites updates
    var sellectallSwitch : Bool = false;
    
    var popController : MyListTrashUndo!;
    var navbardelegate_mainview : ContainerMainView_ChangeNavBarDelegate?
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Install notifications so this VC will recieve acknowledgment when menu options set up in ContainerMainView are pressed
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BrowseItems_MyLists.selectallPressed), name: "selectallPressedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BrowseItems_MyLists.cutcopyPressed), name: "cutcopyPressedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BrowseItems_MyLists.trashPressed), name: "trashPressedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BrowseItems_MyLists.cancelPressed), name: "cancelPressedNotification", object: nil)
        
        navbardelegate_mainview?.setthecutcopyitems_mainview();
        
        pulldata();
        
        tableView.estimatedRowHeight = 300.0 * goldenRatio
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.separatorStyle = .SingleLine
        self.tableView.separatorColor = UIColor.lightGrayColor();
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     When "Move" is initiated in the WordLists_CutCopy dialog, this is triggered to
     remove the rows from the dataset and reset the table
     
     - parameter selectedRowstoRemove: map with [row index number : word id] for those rows which have been selected by the user
     */
    func removeidsandreload(selectedRowstoRemove : [Int : Int]) {
        //Iterate through the PKey array and remove any indexes that are in the selectedRows index.Row
        
        var indexestoremovefromPKeyArray = [Int]();
        for entry in selectedRowstoRemove.keys {
            indexestoremovefromPKeyArray.append(entry);
            
        }
        
        let sortedindexes = Array(indexestoremovefromPKeyArray).sort(>);
        for x in 0 ..< sortedindexes.count {
            print("remove sortedindexes[x]: \(sortedindexes[x])")
            mDataSet.removeAtIndex(sortedindexes[x])
        }
        
        selectedRows = [Int : Int](); // [RowIndexPath : PKey], tracks selected rows for favorites updates
        sellectallSwitch = false;
        
    }
    
    
    func reloadtableselector_mylist(){
        updatetable { (success) -> Void in
            if success {
                self.tableView.reloadData();
                
            }
        }
    }
    
    func updatetable(completion: (success: Bool) -> Void) {
        pulldata()
        completion(success: true)
    }
    
    
    /**
     Creates list of WordEntry objects for each word contained in the current list
     */
    func pulldata() {
        
        if SQLiteDataStore.sharedInstance.myDatabase.open() {
            
            SQLiteDataStore.attachInternalxDB()
            
            let queryPullBrowseItemsData = String(sep:", ",
                                                  
                                                  "SELECT DISTINCT [_id] ",
                                                  ",[Kanji] ",
                                                  ",[Furigana] ",
                                                  ",[Definition] ",
                                                  "FROM [Edict] ",
                                                  "WHERE [_id] IN ( ",
                                                  "SELECT [_id] ",
                                                  "FROM [JFavorites] ",
                                                  "WHERE ([Sys] = \(currentMyList.sys) and [Name] = '\(currentMyList.name)') ",
                                                  ") ORDER BY [_id] "
            );
            
            
            let results:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery(queryPullBrowseItemsData,
                                                                                              withArgumentsInArray: nil)
            var idStringBuilder = "";
            mDataSet = [WordEntry]();
            if (results != nil) {
                while (results.next()) {
                    
                    mDataSet.append(WordEntry(_id: Int(results.stringForColumn("_id")), kanji: results.stringForColumn("Kanji"), furigana: results.stringForColumn("Furigana"), definition: results.stringForColumn("Definition")));
                    
                    if (idStringBuilder.characters.count > 0) {
                        idStringBuilder.appendContentsOf(", ");
                    }
                    idStringBuilder.appendContentsOf(results.stringForColumn("_id"));
                    
                }
            }
            
            
            // Fill in favorite list information for the words
            if(idStringBuilder.characters.count > 0){
                let currentFavoritesForResultSet : [Int : StarColorData] = getCurrentFavoritesForWordIds(idStringBuilder, database: SQLiteDataStore.sharedInstance.myDatabase, colorlistsPrefs: availableWordLists.systemlists);
                
                //Add favorite list information for words in the result set
                for i in 0 ..< mDataSet.count {
                    
                    if(currentFavoritesForResultSet.keys.contains(mDataSet[i]._id)) {
                        mDataSet[i].favoriteLists = currentFavoritesForResultSet[mDataSet[i]._id];
                    }
                }
                
            }
            
            
            SQLiteDataStore.sharedInstance.myDatabase.close()
        } else {
            print("Error3: \(SQLiteDataStore.sharedInstance.myDatabase.lastErrorMessage())")
        }
        
    }
    
}


extension BrowseItems_MyLists {
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDataSet.count
    }
    
    
    // Cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("BrowseItemsCell_MyLists") as! customTableViewCell_BrowseItem_MyLists!
        if cell == nil {
            cell = customTableViewCell_BrowseItem_MyLists(style: UITableViewCellStyle.Default, reuseIdentifier: "BrowseItemsCell_MyLists")
        }
        
        cell.selectionStyle = .None
        
        //Set selected (on reload)
        if(selectedRows.keys.contains(indexPath.row)) {
            cell.backgroundColor = UIColor(hex: 0xBBDEFB)
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        /** Push the kanji _id and hash of mylists that the _id is in to the "customTableViewCell_BrowseItem class, so these can be passed back and forth between that class and the MyListChooserPopover */
        cell.pkey = mDataSet[indexPath.row]._id;
        cell.mcellKanji.text = mDataSet[indexPath.row].getDisplayKanji();
        cell.mcellDefinition.text = mDataSet[indexPath.row].getDisplayDefinition();
        cell.mcellKanji.font = cell.mcellKanji.font.fontWithSize(17 * goldenRatio)
        cell.mcellDefinition.font = cell.mcellDefinition.font.fontWithSize(14 * goldenRatio)
        
        cell.separatorInset = UIEdgeInsetsMake(1.0 * goldenRatio, cell.bounds.size.width, 0.0, 0.0);
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! customTableViewCell_BrowseItem_MyLists
        
        
        if(cell.pkey != nil ) {
            
            // If the cell is not already selected, then select it
            if(!selectedRows.keys.contains(indexPath.row)) {
                print("SELECTING A ROW: \(indexPath.row)")
                selectedRows[indexPath.row] = cell.pkey;
                cell.backgroundColor = UIColor(hex: 0xBBDEFB)
            } else {
                print("DESELECTING A ROW:\(indexPath.row)")
                if(selectedRows.keys.contains(indexPath.row)) {
                    selectedRows.removeValueForKey(indexPath.row);
                    cell.backgroundColor = UIColor.clearColor()
                }
            }
            
        }
        
        if(mDataSet.count == selectedRows.count) {
            print("SETTING SELECTED ALL")
            sellectallSwitch = true;
        } else {
            sellectallSwitch = false;
        }
        
        // If more than one row is selected, show the cut/copy/selectall/cancel menu options, otherwise hide it
        navbardelegate_mainview?.showthecutcopyitems_mainview((selectedRows.count > 0))
    }
    
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! customTableViewCell_BrowseItem_MyLists
        
        if(cell.pkey != nil ) {
            
            // If the cell is not already selected, then select it
            if(!selectedRows.keys.contains(indexPath.row)) {
                print("SELECTING A ROW: \(indexPath.row)")
                selectedRows[indexPath.row] = cell.pkey;
                cell.backgroundColor = UIColor(hex: 0xBBDEFB)
            } else {
                print("DESELECTING A ROW:\(indexPath.row)")
                if(selectedRows.keys.contains(indexPath.row)) {
                    selectedRows.removeValueForKey(indexPath.row);
                    cell.backgroundColor = UIColor.clearColor()
                }
            }
            
        }
        
        if(mDataSet.count == selectedRows.count) {
            sellectallSwitch = true;
        } else {
            sellectallSwitch = false;
        }
        
        //If more than one row is selected, show the white star favorites button up top
        if(selectedRows.count > 0 ) {
            navbardelegate_mainview?.showthecutcopyitems_mainview(true)
        } else {
            navbardelegate_mainview?.showthecutcopyitems_mainview(false)
        }
    }
    
    
    /**
     De-Selects all selected rows when user clicks "Cancel" button in the action bar
     */
    func cancelPressed() {
        print("CANCEL WAS PRESSED!!!")
        
        navbardelegate_mainview?.showthecutcopyitems_mainview(false)
        sellectallSwitch = false;
        selectedRows = [Int : Int]();
        
        self.tableView.reloadData();
    }
    
    /**
     Selects all rows in the list when user clicks "Select All" button in the action bar
     */
    func selectallPressed(){
        print("current selectal switch: \(sellectallSwitch)")
        
        if(sellectallSwitch == false) {
            sellectallSwitch = true;
            
            selectedRows = [Int : Int]();
            for i in 0 ..< mDataSet.count {
                selectedRows[i] = Int(mDataSet[i]._id);
            }
            
            navbardelegate_mainview?.showthecutcopyitems_mainview(true)
        } else {
            sellectallSwitch = false;
            navbardelegate_mainview?.showthecutcopyitems_mainview(false)
            selectedRows = [Int : Int]();
            
        }
        
        
        print("SELECTED ROWS ALL VALUES: \(selectedRows.values)")
        self.tableView.reloadData();
        
    }
    
    
    
    /**
     Shows BrowseItems_MyLists_CutCopy dialog allowing user to move/copy selected rows from the current list. This method is
     called from a ContainerMainView callback, when the user presses the Cut/Copy button in the action bar
     */
    func cutcopyPressed(){
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mylistcutcopy") as! BrowseItems_MyLists_CutCopy
        
        popController.currentmylist = currentMyList;
        popController.selectedRows = selectedRows;
        popController.delegate = self;
        popController.colorlistsPrefs = availableWordLists.systemlists;
        
        let prefpopupwidth = 320 * goldenRatio;
        var prefpopupheight = 500 * goldenRatio;
        if(mylistrowcount > 0) {
            let prospectiveRowHeight = 26.0 * goldenRatio * CGFloat(mylistrowcount) + 100.0 * goldenRatio;
            
            if(prospectiveRowHeight < (500 * goldenRatio)) {
                prefpopupheight = 26.0 * goldenRatio * CGFloat(mylistrowcount) + 100.0 * goldenRatio;
                
            }
            
            popController.tableviewheight = 26.0 * goldenRatio * CGFloat(mylistrowcount)
            print("mylistrowcount: \(mylistrowcount), prefpopupheight: \(prefpopupheight)")
        }
        
        
        popController.modalPresentationStyle = UIModalPresentationStyle.Popover
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        popController.popoverPresentationController?.sourceView = self.view
        popController.popoverPresentationController?.delegate = self
        popController.preferredContentSize = CGSize(width: Int(prefpopupwidth), height: Int(prefpopupheight))
        popController.popoverPresentationController?.sourceRect = CGRectMake(CGFloat(CGRectGetMidX(self.view.bounds)),CGFloat(CGRectGetMidY(self.view.bounds)) + 64 * goldenRatio,0,0)
        self.presentViewController(popController, animated: true, completion: nil)
        
    }
    
    
    /**
     Removes selected rows from the JFavorites table in the database as well as the current dataset, and refreshes table to reflect changes. Also
     shows an "undo" popup, allowing user to unwind the process (Re-Inserting rows and updating table again) if they press "undo". This method is
     called from a ContainerMainView callback, when the user presses the Trash button in the action bar
     */
    func trashPressed() {
        
        // Create a concatenated string of the selected rows
        var thefirstone = true;
        var idstodelete  = "";
        for entry in selectedRows.values {
            if(thefirstone != true) {
                idstodelete.appendContentsOf(",");
            }
            thefirstone = false;
            idstodelete.appendContentsOf(String(entry));
        }
        
        // Save a restore (backup) version of the pkey array, in case user undoes the delete
        let tmpDataSet = mDataSet;
        
        print("idstodelete: \(idstodelete)");
        
        // Delete selected rows from the DB
        let listItemsToRemove = MyListEntry(name: currentMyList.name, sys: currentMyList.sys, checkedstatus: nil, idstoaddorremove: idstodelete)
        
        do {
            defer { self.tableView.reloadData()}
            
            SQLiteDataStore.deleteWordsFromFavorites(listItemsToRemove)
            
            var indexestoremovefromPKeyArray = [Int]();
            for entry in selectedRows.keys {
                indexestoremovefromPKeyArray.append(entry);
                
            }
            
            let sortedindexes = Array(indexestoremovefromPKeyArray).sort(>);
            
            for x in 0 ..< sortedindexes.count {
                print("sortedindexes[x]: \(sortedindexes[x])")
                
                mDataSet.removeAtIndex(sortedindexes[x])
            }
            
            selectedRows = [Int : Int](); // [RowIndexPath : PKey], tracks selected rows for favorites updates
            sellectallSwitch = false;
        }
        
        
        navbardelegate_mainview?.showthecutcopyitems_mainview(false)
        reloadMainMyListController();
        sellectallSwitch = false;
        selectedRows = [Int : Int]();
        
        
        // Update the table, and display the "Undo" popover
        popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mylist_trash_undo") as! MyListTrashUndo
        popController.modalPresentationStyle = UIModalPresentationStyle.Popover
        let screenBounds = UIScreen.mainScreen().bounds
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = tableView // button
        popController.popoverPresentationController?.sourceRect = CGRectMake(CGFloat(CGRectGetMidX(self.view.bounds) - 10.0) , CGFloat(CGRectGetMaxY(tableView.bounds) - screenBounds.height * 0.2),0,0)
        popController.delegate = self
        
        let bounds = UIScreen.mainScreen().bounds
        var shorterlength : CGFloat;
        if(bounds.width > bounds.height) {
            shorterlength = bounds.height
        } else {
            shorterlength = bounds.width
        }
        
        popController.preferredContentSize = CGSize(width: Int(shorterlength * 0.8), height: Int(50 * goldenRatio))
        popController.listdata = listItemsToRemove;
        popController.tmpDataSet = tmpDataSet;
        
        NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(dismissTrashUndo), userInfo: nil, repeats: false)
        
        self.presentViewController(popController, animated: true, completion: nil)
        
    }
    
    
    /**
     Dismisses the "Undo delete" popup that shows for a few seconds after the user deletes rows from the current list.
     */
    func dismissTrashUndo(){
        
        if(popController != nil ) {
            popController.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    /**
     Unwinds recently deleted rows when user clicks "undo delete" in the TrashUndo popup
     */
    func trashPressedUndo(tmpDataSet : [WordEntry] ){
        mDataSet = tmpDataSet;
        tableView.reloadData();
        
        if(popController != nil) {
            print("pop isn't nil");
            popController.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        let screenBounds = UIScreen.mainScreen().bounds
        
        
        dispatch_async(dispatch_get_main_queue(),
                       
                       {
                        
                        self.tableView.contentInset = setTableInset(screenBounds.width, height: screenBounds.height, goldenRatio: self.goldenRatio, extrapoints: 0, extrasubtract: 0, bottominset: 0);
                        if(self.mDataSet.count > 0) {
                            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
                        }
                        
            }
        )
    }
    
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        
        let lengths = lengthsizes();
        
        let triggerTime = (Int64(NSEC_PER_MSEC) * 200)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            
            if(toInterfaceOrientation.isLandscape) {
                self.tableView.contentInset = setTableInset(lengths.1, height: lengths.0, goldenRatio: self.goldenRatio, extrapoints: 0, extrasubtract: 0, bottominset: 0);
            } else {
                self.tableView.contentInset = setTableInset(lengths.0, height: lengths.1, goldenRatio: self.goldenRatio, extrapoints: 0, extrasubtract: 0, bottominset: 0);
            }
        })
        
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection)  -> UIModalPresentationStyle {
        return .None
    }
    
    func reloadMainMyListController() {
        
        if(navbardelegate_mainview != nil) {
            navbardelegate_mainview?.reloadmainlistcontroller();
        }
    }
    
    
    
}

extension BrowseItems_MyLists: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        reloadtableselector_mylist();
        return DismissAnimator()
    }
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}






