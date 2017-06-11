//
//  Search.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit



// User can search Edict dictionary entries by Kanji (Romaji) or Definition. Then save word entries to Word Lists with the favorites star.
class Search_test: UIViewController , UITableViewDelegate, UITableViewDataSource , UISearchBarDelegate, customCell_ListChooserDelegate, MyListChooserPopoverDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate , UITextFieldDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var txtSearchOn: UILabel!
    @IBOutlet weak var txtNoResults: UILabel!
    @IBOutlet weak var checkboxRomaji: UIButton!
    @IBOutlet weak var checkboxDefinition: UIButton!
    
    //If selected, the search will be for Romaji characters
    @IBAction func checkboxRomaji_pressed(sender: UIButton) {
        romajitoggle();
    }
    
    //If selected, the search will be for the Dictionary definition of the word
    @IBAction func checkboxDefinition_pressed(sender: UIButton) {
        romajitoggle();
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var txtRomaji: UILabel!
    @IBOutlet weak var txtDefinition: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var clearButton : UIButton!;
    
    let interactor = Interactor()
    var searchResults = [WordEntry]();
    var availableWordLists : StarColorData = StarColorData();
    var rowheightarray = [Int]();
    var longpressid : Int!;
    var selectedRows = [NSIndexPath : Int](); // [RowIndexPath : PKey], tracks selected rows for favorites updates
    var showtheresults = false;
    var romajiischecked : Bool = true;
    var alert : AlertHelper = AlertHelper();
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds)
    let screenBounds = UIScreen.mainScreen().bounds;
    var showresultsanchor : NSLayoutConstraint!;
    var hideresultsanchor : NSLayoutConstraint!;
    var popController_mylistchooser : MyListChooserPopover!;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultPreferences();
        SQLiteDataStore.createDefaultTables();
        
        availableWordLists.systemlists = NSUserDefaults.standardUserDefaults().stringArrayForKey("favoritesstarsarray") as [String]!;
        availableWordLists.otherlists = getUserCreatedLists();
        
        txtNoResults.hidden = true;
        
        clearButton = UIButton(frame: CGRectMake(0, 0, 30 * self.goldenRatio, 30 * self.goldenRatio))
        clearButton.setImage(UIImage(named: "ic_clear")!, forState: UIControlState.Normal)
        clearButton.addTarget(self, action: #selector(self.clearClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        clearButton.userInteractionEnabled = true;
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        txtRomaji.userInteractionEnabled = true
        txtRomaji.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(romajitoggle)))
        txtDefinition.userInteractionEnabled = true
        txtDefinition.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(romajitoggle)));
        
        setFormattingandConstraints();
        
        checkboxRomaji.setImage(UIImage(named: "ic_check_box")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        checkboxDefinition.setImage(UIImage(named: "ic_check_box_outline_blank")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        tableView.estimatedRowHeight = 300.0 * goldenRatio
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.separatorStyle = .SingleLine
        self.tableView.separatorColor = UIColor.lightGrayColor();
        
        searchBar.delegate = self
        self.searchBar.layoutIfNeeded()
    }
    
    
    /**
     Toggles selection of the  "Romaji" and "Dictionary" checkboxes. Only one checkbox can be selected at a time. If one is selected, the other becomes unselected.
     */
    func romajitoggle() {
        if(romajiischecked == true) {
            romajiischecked = false;
            checkboxRomaji.setImage(UIImage(named: "ic_check_box_outline_blank")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            checkboxDefinition.setImage(UIImage(named: "ic_check_box")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            
        } else {
            romajiischecked = true;
            checkboxRomaji.setImage(UIImage(named: "ic_check_box")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            checkboxDefinition.setImage(UIImage(named: "ic_check_box_outline_blank")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            
        }
    }
    
    
    // Search bar "clear" button empties the searchField
    func clearClicked(sender:UIButton)
    {
        if let textFieldInsideUISearchBar = searchBar.valueForKey("searchField") as? UITextField {
            textFieldInsideUISearchBar.text = ""
        }
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if(goldenRatio > 1) {
            resetSearchBar()
        }
    }
    
    
    
    
    
    // Initiates search when search button is clicked. Shows "search in progress" message.
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        print("Button clicked")
        let query = (searchBar.text?.lowercaseString)!;
        
        
        if(romajiischecked && query.contains(" ")) {
            
            self.txtNoResults.text = "Romaji searches must not include spaces"
            self.txtNoResults.hidden = false;
            self.showresultsanchor.active = true;
            self.hideresultsanchor.active = false;
            self.tableView.hidden = true;
            
        } else if (query.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()).characters.count == 0) {
            self.txtNoResults.text = "Search query must not be empty"
            self.txtNoResults.hidden = false;
            self.showresultsanchor.active = true;
            self.hideresultsanchor.active = false;
            self.tableView.hidden = true;
            
        } else {
            self.txtNoResults.text = "No results found"
            self.txtNoResults.hidden = true;
            self.showresultsanchor.active = false;
            self.hideresultsanchor.active = true;
            self.tableView.hidden = false;
            self.view.endEditing(true)
            
            alert.showAlert(fromController: self, messagetoshow: "Searching...", indicator: true, goldenRatio: goldenRatio)
            
            if(romajiischecked) {
                runRomajiSearchQuery(query, completion: { success in
                    self.onSearchSuccessAction(success);
                })
            } else {
                runDictionarySearchQuery(query, completion: { success in
                    self.onSearchSuccessAction(success);
                })
            }
            
        }
        
        
        
    }
    
    /**
     When search concludes, either shows result set or "no results found" message
     */
    private func onSearchSuccessAction(success : Bool) {
        if success {
            
            if(!self.isBeingPresented()) {
                self.dismissViewControllerAnimated(false, completion: nil)
            }
            
            self.tableView.reloadData();
            
            if(self.searchResults.count == 0) {
                self.txtNoResults.hidden = false;
                self.showresultsanchor.active = true;
                self.hideresultsanchor.active = false;
                self.tableView.hidden = true;
                
            } else {
                self.txtNoResults.hidden = true;
                self.showresultsanchor.active = false;
                self.hideresultsanchor.active = true;
                self.tableView.hidden = false;
            }
        } else {
            
            if(!self.isBeingPresented()) {
                self.dismissViewControllerAnimated(false, completion: nil)
            }
            
            print("NOT SUCCESSFULLL :( ")
            
            self.txtNoResults.hidden = false;
            self.showresultsanchor.active = true;
            self.hideresultsanchor.active = false;
            self.tableView.hidden = true;
        }
        
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        tableView.reloadData();
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BrowseItemsCell",forIndexPath: indexPath) as! customTableViewCell_BrowseItem;
        
        cell.selectionStyle = .None
        
        var wordEntry = searchResults[indexPath.row];
        cell.wordEntry = wordEntry;
        cell.mCellDelegate = self;
        cell.starOrigin = cell.frame.origin;
        cell.availableWordLists = availableWordLists;
        cell.cellKanji.text = wordEntry.getDisplayKanji();
        cell.cellDefinition.text = wordEntry.getDisplayDefinition();
        cell.rowIndexPath = indexPath;
        
        
        // Handle the Coloring of the star
        let image = UIImage(named: "ic_star_black")?.imageWithRenderingMode(.AlwaysTemplate)
        cell.star.setImage(image, forState: .Normal)
        cell.star.userInteractionEnabled = true;
        
        if(availableWordLists.getTotalWordListCount() == 0) {
            cell.star.tintColor = UIColor.clearColor()
            cell.star.userInteractionEnabled = false;
            
        } else if(wordEntry.favoriteLists.systemlists.count>1) {
            
            // Show mult-colored star image if the word is associated with more than one system list
            let image_multi = UIImage(named: "ic_star_multicolor")?.imageWithRenderingMode(.AlwaysOriginal)
            cell.star.setImage(image_multi, forState: .Normal)
            cell.star.tintColor = .None
            
        } else if(wordEntry.favoriteLists.systemlists.count == 1) {
            switch String(wordEntry.favoriteLists.systemlists[0]) {
            case "Blue":
                cell.star.tintColor = UIColor.blueColor()
            case "Green":
                cell.star.tintColor = UIColor.greenColor()
            case "Red":
                cell.star.tintColor = UIColor.redColor()
            case "Yellow":
                cell.star.tintColor = UIColor.yellowColor()
            default:
                cell.star.tintColor = UIColor.blackColor()
                break;
            }
            
        } else {
            cell.star.tintColor = UIColor.blackColor()
        }
        
        
        // A long-press on the favorites star will always open the MyListChooserPopover. Only add the gesture recognizer if the Popover won't already be displayed with a regular "onClick" (like if a word is already associated with multiple lists)
        if(!wordEntry.favoriteLists.shouldOpenListPopoverOnClick()) {
            let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(starlongpress(_:)))
            longPressGesture.minimumPressDuration = 0.8 // 1 second press
            longPressGesture.delegate = self
            cell.star.addGestureRecognizer(longPressGesture)
        }
        
        cell.separatorInset = UIEdgeInsetsMake(1.0 * goldenRatio, cell.bounds.size.width, 0.0, 0.0);
        cell.cellKanji.font = cell.cellKanji.font.fontWithSize(17 * goldenRatio)
        cell.cellDefinition.font = cell.cellKanji.font.fontWithSize(14 * goldenRatio)
        
        // Make sure star button is correctly proportioned and centered
        let buttonheight = 24.0 * goldenRatio;4
        cell.star.frame = CGRectMake(0,0,buttonheight,buttonheight)
        cell.star.widthAnchor.constraintEqualToConstant(buttonheight).active = true;
        cell.star.heightAnchor.constraintEqualToConstant(buttonheight).active = true;
        
        NSLayoutConstraint(item: cell.star, attribute: .CenterY, relatedBy: .Equal, toItem: cell, attribute: .CenterY, multiplier: 1, constant: 0).active = true;
        cell.star.trailingAnchor.constraintEqualToAnchor(cell.star.superview?.trailingAnchor, constant: -8 * goldenRatio).active = true;
        cell.star.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
        cell.star.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
        
        return cell
    }
    
    
    /**
     When the user clicks the favorite star in the customTableViewCell_BrowseItem (and word is added/removed
     from the db favorite list table), the message is relayed through this method so that the Search dataset
     and ListController_MyLists VC can be updated to reflect the change
     
     - parameter dataSetIndex: index of item in dataset to be updated
     - parameter updatedFavorites: new favorites info to overwrite to dataset item
     */
    func retrieveUpdatedFavorites(dataSetIndex: Int, updatedFavorites: StarColorData) {
        
        // Update favorite lists info for word in search results dataset
        if(searchResults.count>dataSetIndex) {
            searchResults[dataSetIndex].favoriteLists = updatedFavorites
        }
        
        //Updates the ListController_MyLists VC to reflect changes
        tellNavContoUpdateMainViews(true)
    }
    
    
    /**
     Displays the MyListChooserPopover when users long-presses the favorites star for a search result, or regular clicks the star if
     that word is associated with more than one list. The MyListChooserPopover allows user to quickly add the word to many lists.
     
     - parameter wordEntry: WordEntry object for current item in dataset
     - parameter starOrigin: location of favorite star on screen, so the choose favorites window will appear at the right place
     - parameter availableWordLists: array of possible word lists that the word can be added to
     - parameter rowIndexPath: index of item in dataset (so dataset can be updated when changes are made)
     
     */
    func showListChooserPopover(wordEntry : WordEntry,starOrigin: CGPoint!, availableWordLists: StarColorData,rowIndexPath: NSIndexPath  ) {
        
        popController_mylistchooser = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mylistselector") as! MyListChooserPopover
        
        var starpoint :CGFloat;
        if(starOrigin == nil) {
            let tablerect = tableView.rectForRowAtIndexPath(rowIndexPath)
            starpoint =  tablerect.midY
        } else {
            starpoint = starOrigin.y
        }
        
        // Create a set of MyListEntries for the wordlists that are available/already associated with the wordentry in question
        var listChooserDataSet = [MyListEntry]();
        for listName in availableWordLists.systemlists {
            if(wordEntry.favoriteLists.systemlists.contains(listName)) {
                listChooserDataSet.append(MyListEntry(name: listName, sys: 1, checkedstatus: 1, idstoaddorremove: String(wordEntry._id)))
            } else {
                listChooserDataSet.append(MyListEntry(name: listName, sys: 1, checkedstatus: 0, idstoaddorremove: String(wordEntry._id)))
            }
        }
        
        for listName in availableWordLists.otherlists {
            if(wordEntry.favoriteLists.otherlists.contains(listName)) {
                listChooserDataSet.append(MyListEntry(name: listName, sys: 0, checkedstatus: 1, idstoaddorremove: String(wordEntry._id)))
            } else {
                listChooserDataSet.append(MyListEntry(name: listName, sys: 0, checkedstatus: 0, idstoaddorremove: String(wordEntry._id)))
            }
        }
        
        popController_mylistchooser.mWordEntry = wordEntry;
        popController_mylistchooser.rowIndexPath = rowIndexPath;
        popController_mylistchooser.mDataSet = listChooserDataSet;
        popController_mylistchooser.mDelegate = self;
        
        var shorterlength : CGFloat;
        let screenbounds = UIScreen.mainScreen().bounds;
        if(screenbounds.width > screenbounds.height) {
            shorterlength = screenbounds.height;
        } else {
            shorterlength = screenbounds.width
        }
        let prefpopupwidth = 0.5 * shorterlength;
        popController_mylistchooser.modalPresentationStyle = UIModalPresentationStyle.Popover
        popController_mylistchooser.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        popController_mylistchooser.popoverPresentationController?.sourceView = self.view
        popController_mylistchooser.popoverPresentationController?.delegate = self
        
        var prefpopupheight = availableWordLists.getTotalWordListCount() * Int(26.0 * goldenRatio)
        
        if(listChooserDataSet.count > 0) {
            prefpopupheight = listChooserDataSet.count * Int(26.0 * goldenRatio) + Int(6 * goldenRatio);
        } else if(popController_mylistchooser.tableView.rectForSection(0).height != nil) {
            prefpopupheight = Int(popController_mylistchooser.tableView.rectForSection(0).height);
            
        }
        popController_mylistchooser.preferredContentSize = CGSize(width: Int(prefpopupwidth), height: prefpopupheight)
        
        popController_mylistchooser.popoverPresentationController?.sourceRect = CGRectMake(CGFloat(UIScreen.mainScreen().bounds.width - 50.0*goldenRatio - (prefpopupwidth * 0.5) ) , CGFloat(starpoint + (88 + 44)*goldenRatio),0,0)
        
        self.presentViewController(popController_mylistchooser, animated: true, completion: nil)
    }
    
    
    func dismissMyListChooserPopover() {
        if(popController_mylistchooser != nil) {
            popController_mylistchooser.dismissViewControllerAnimated(true, completion: nil);
            popController_mylistchooser = nil;
        }
        
    }
    
    
    /**
     When the user adds or removes a word from a MyList in the MyListChooserPopover, the message is relayed through this method so that the Search dataset,
     customTableViewCell_BrowseItem and ListController_MyLists VC can be updated to reflect the change
     
     - parameter updatedFavorites: new favorites info to overwrite to dataset item
     - parameter rowIndexPath: index of item in dataset
     */
    func retrieveUpdatedFavoritesFromMyListChooser(updatedFavorites: StarColorData, rowIndexPath: NSIndexPath?) {
        
        retrieveUpdatedFavorites((rowIndexPath?.row)!, updatedFavorites: updatedFavorites);
        
        let cell = tableView.cellForRowAtIndexPath(rowIndexPath!) as! customTableViewCell_BrowseItem
        cell.wordEntry?.favoriteLists = updatedFavorites;
        
        // There are multiple lists selected
        if(updatedFavorites.shouldOpenListPopoverOnClick()) {
            
            // Handle the Coloring of the star
            var image = UIImage(named: "ic_star_black")?.imageWithRenderingMode(.AlwaysTemplate)
            cell.star.setImage(image, forState: .Normal)
            
            if(updatedFavorites.systemlists.count>1) {
                
                image = UIImage(named: "ic_star_multicolor")?.imageWithRenderingMode(.AlwaysOriginal)
                cell.star.setImage(image, forState: .Normal)
                
            } else if(updatedFavorites.systemlists.count == 1) {
                switch String(updatedFavorites.systemlists[0]) {
                case "Blue":
                    cell.star.tintColor = UIColor.blueColor()
                case "Green":
                    cell.star.tintColor = UIColor.greenColor()
                case "Red":
                    cell.star.tintColor = UIColor.redColor()
                case "Yellow":
                    cell.star.tintColor = UIColor.yellowColor()
                default:
                    cell.star.tintColor = UIColor.blackColor()
                    break;
                }
            } else {
                cell.star.tintColor = UIColor.blackColor()
            }
        }
        
        tableView.reloadRowsAtIndexPaths([rowIndexPath!], withRowAnimation: UITableViewRowAnimation.None)
        tableView.selectRowAtIndexPath(rowIndexPath!, animated: false, scrollPosition: .None)
        (tableView.cellForRowAtIndexPath(rowIndexPath!) as! customTableViewCell_BrowseItem).star.hidden = false;
        tellNavContoUpdateMainViews(true)
    }
    
    
    
    /**
     Searches Edict dictionary for matches on kanji or furigana, which involves firt converting the english "Romaji" query string
     into translated Hiragana and Katakana strings, then searching the Edict dictionary and returning a set of WordEntries that match
     
     - parameter search query string (in English "Romaji" characters)
     - parameter bool true if search was successful, false if not
     */
    func runRomajiSearchQuery(query : String, completion: ((Bool)->())?) {
        
        
        // Reset all the lists and whatnot
        var possibleHiraganaSearchQueries = [String]();
        var possibleKatakanaSearchQueries = [String]();
        
        searchResults.removeAll();
        print("GET ROMAJI BEFORE")
        let romajiSearchMap : [String : [RomajiTranslation]] = getRomaji();
        
        // Trim query
        let trimmedQuery =  query.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //Convert the query from English Romaji --> Japanese Furigana and Katakana
        var startposition = 0;
        var iterator = 3;
        
        if(trimmedQuery.characters.count < iterator){
            iterator = 2;
        }
        
        var foundone = false;
        
        
        while(trimmedQuery.characters.count >= (startposition + iterator) && trimmedQuery.characters.count - startposition > 0) {
            
            while(iterator > 0 && !foundone) {
                
                let querychunk : String =  trimmedQuery.substringWithRange(Range<String.Index>(trimmedQuery.startIndex.advancedBy(startposition) ..< trimmedQuery.startIndex.advancedBy(startposition+iterator))).lowercaseString;
                
                print("QUERYCHUNK: \(querychunk)");
                
                // Japenese-specific rule: If it's a 3 char double like: ppu --> っぷ , add in the っ/ッ character, unless it's a "nn"
                if(iterator == 2 && String(querychunk[0]).caseInsensitiveCompare(String(querychunk[1])) == NSComparisonResult.OrderedSame && String(querychunk[0]) != "n") {
                    
                    possibleHiraganaSearchQueries = [String] (addPossibleSearchQueries(possibleHiraganaSearchQueries,additionalCharacters: "っ"));
                    possibleKatakanaSearchQueries = [String] (addPossibleSearchQueries(possibleKatakanaSearchQueries,additionalCharacters: "ッ"));
                    
                    iterator -= 1;
                    foundone = true;
                    
                } else {
                    
                    /* If the current section of the search query can be converted from romaji to Hiragana/Katakana,
                     attach the hiragana and katakana pieces to their respective converted search query strings */
                    if(romajiSearchMap.keys.contains(querychunk)){
                        foundone = true;
                        
                        for currentRomajiTranslation in romajiSearchMap[querychunk]! {
                            
                            possibleHiraganaSearchQueries = [String](addPossibleSearchQueries(possibleHiraganaSearchQueries,additionalCharacters: currentRomajiTranslation.hiragana));
                            
                            possibleKatakanaSearchQueries = [String](addPossibleSearchQueries(possibleKatakanaSearchQueries,additionalCharacters: currentRomajiTranslation.katakana));
                        }
                        
                    } else {
                        iterator -= 1;
                        
                    }
                    
                }
                
            }
            
            
            if(!foundone) {
                iterator = 3;
                startposition = (startposition + 3);
                
            } else {
                
                startposition = (startposition + iterator);
                iterator = 3;
                foundone = false;
            }
            
            while(iterator > 0 && query.characters.count - startposition > 0 && query.characters.count < (startposition+iterator)){
                iterator -= 1;
            }
            
        }
        
        
        // Now try to find DB matches for the query
        if (SQLiteDataStore.sharedInstance.myDatabase.open()) {
            SQLiteDataStore.attachInternalxDB()
            print("ok opening db again")
            
            var atleastoneisfound = false;
            var idstopasson = "";
            var idStringBuilder = "";
            
            // First, search for katakana & hiragana ONLY words
            if(possibleKatakanaSearchQueries.count > 0 && !query.contains(" ")) {
                
                for a in 0 ..< possibleKatakanaSearchQueries.count {
                    
                    let results:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery("Select _id from Edict Where Furigana is null and [Kanji] like ? Order by Common Limit 15", withArgumentsInArray: ["%\(possibleKatakanaSearchQueries[a])%"])
                    
                    if(results != nil) {
                        atleastoneisfound = true;
                        while (results.next()) {
                            
                            if (idStringBuilder.characters.count > 0) {
                                idStringBuilder.appendContentsOf(", ");
                            }
                            idStringBuilder.appendContentsOf(results.stringForColumn("_id"));
                            
                        }
                        results.close();
                    }
                    
                    
                }
                
            }
            
            // Next, search for Kanji by matching their furigana
            if(possibleHiraganaSearchQueries.count > 0 && !query.contains(" ")) {
                
                for a in 0 ..< possibleHiraganaSearchQueries.count {
                    
                    print("RUNNING B")
                    
                    let results:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery("Select _id from Edict Where Furigana is not null and [Furigana] like ? Order by Common Limit 20", withArgumentsInArray: ["%\(possibleHiraganaSearchQueries[a])%"])
                    
                    if(results != nil) {
                        atleastoneisfound = true;
                        
                        while (results.next()) {
                            
                            if (idStringBuilder.characters.count > 0) {
                                idStringBuilder.appendContentsOf(", ");
                            }
                            idStringBuilder.appendContentsOf(results.stringForColumn("_id"));
                        }
                        
                    }
                    results.close();
                    
                }
                
            }
            
            
            
            // If there is at least on positive match, pull further edict data from Edict dictionary.
            if(atleastoneisfound == true) {
                idstopasson = idStringBuilder;
                
                createSearchResultWordEntries(SQLiteDataStore.sharedInstance.myDatabase,idstopasson: idstopasson);
                
                showtheresults = true;
                completion?(true)
                
            } else {
                showtheresults = false;
                completion?(false)
            }
            
            
            SQLiteDataStore.sharedInstance.myDatabase.close();
        }
        
        
    }
    
    
    /**
     Searches Edict dictionary for matches on word definition, and returns a set of
     WordEntries that match
     
     - parameter search query string
     - parameter bool true if search was successful, false if not
     */
    func runDictionarySearchQuery(query : String, completion: ((Bool)->())?) {
        
        // Reset all the lists and whatnot
        var definitionquerypositionarray = [String]();
        searchResults.removeAll();
        
        // Trim query
        let trimmedQuery =  query.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        //Try to find DB matches for the query
        if SQLiteDataStore.sharedInstance.myDatabase.open() {
            
            SQLiteDataStore.attachInternalxDB()
            
            
            var atleastoneisfound = false;
            var idstopasson = "";
            var idStringBuilder = "";
            
            
            definitionquerypositionarray = [String]();
            
            
            // Lastly, search for the definition
            print("RUNNING C")
            
            
            let sqlQuery = String(sep:", ",
                                  
                                  "Select _id " +
                                    "FROM " +
                                    "(" +
                                    "Select _id" +
                                    ",Common" +
                                    ",( CASE WHEN SUBSTR(Definition,0,LENGTH(Definition)*(.4)) like ? then 1 Else 2 END) as [Pos] " +
                                    ",LENGTH(Definition) as DefinitionLength " +
                                    "from Edict " +
                                    "Where REPLACE(REPLACE(REPLACE(Definition,\")\",\" \"),\"(\",\" \"),\",\",\" \") like ?" +
                                    ") as [Search] " +
                "Order by Common asc,[Pos] asc, DefinitionLength asc  LIMIT 25"
            );
            
            let results:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery(sqlQuery, withArgumentsInArray: ["%\(trimmedQuery)%","% \(trimmedQuery) %"])
            
            
            if(results != nil) {
                atleastoneisfound = true;
                
                while (results.next()) {
                    
                    if (idStringBuilder.characters.count > 0) {
                        idStringBuilder.appendContentsOf(", ");
                    }
                    idStringBuilder.appendContentsOf(results.stringForColumn("_id"));
                    definitionquerypositionarray.append(results.stringForColumn("_id"));
                }
                results.close();
            } else {
                
                let backupSqlQuery = String(sep:", ",
                                            "Select _id " +
                                                "FROM " +
                                                "(" +
                                                "Select _id" +
                                                ",Common" +
                                                ",LENGTH(Definition) as DefinitionLength " +
                                                ",(CASE WHEN SUBSTR(Definition,0,LENGTH(Definition)*(.4)) like ? then 1 Else 2 END) as [Pos] " +
                                                "from Edict " +
                                                "Where REPLACE(REPLACE(REPLACE(Definition,\")\",\" \"),\"(\",\" \"),\",\",\" \") like ?) as [Search] " +
                    "Order by Common asc ,[Pos] asc, DefinitionLength  asc LIMIT 25"
                );
                
                let results2:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery(backupSqlQuery, withArgumentsInArray: ["%\(trimmedQuery)%","%\(trimmedQuery)%"])
                
                
                if(results2 != nil) {
                    print("RUNNING D")
                    
                    atleastoneisfound = true;
                    
                    while (results2.next()) {
                        
                        if (idStringBuilder.characters.count > 0) {
                            idStringBuilder.appendContentsOf(", ");
                        }
                        idStringBuilder.appendContentsOf(results.stringForColumn("_id"));
                        definitionquerypositionarray.append(results.stringForColumn("_id"));
                        
                    }
                    results2.close()
                }
                
            }
            
            
            
            
            
            // If there is at least on positive match, pull further edict data from Edict dictionary.
            if(atleastoneisfound == true) {
                idstopasson = idStringBuilder;
                
                createSearchResultWordEntries(SQLiteDataStore.sharedInstance.myDatabase,idstopasson: idstopasson);
                
                showtheresults = true;
                completion?(true)
                
            } else {
                showtheresults = false;
                completion?(false)
            }
            
            SQLiteDataStore.sharedInstance.myDatabase.close();
        }
        
        
    }
    
    /**
     Takes the current search query (a string that is being built), and appends the newly translated romaji--> hiragana/katakana characters
     to the string
     
     - parameter possibleSearchQueries: current query that will eventually be searched against the db
     - parameter additionalCharacters: additional piece of text to be appended to the possibleSearchQueries
     */
    private func addPossibleSearchQueries(possibleSearchQueries : [String], additionalCharacters : String) -> [String]{
        
        var matchBuilder = "";
        var updatedPossibleSearchQueries = [String]();
        
        if(possibleSearchQueries.count > 0) {
            
            for query in possibleSearchQueries {
                matchBuilder.appendContentsOf(query);
                matchBuilder.appendContentsOf(additionalCharacters);
                updatedPossibleSearchQueries.append(matchBuilder);
                matchBuilder =  "";
            }
            
        } else {
            updatedPossibleSearchQueries.append(additionalCharacters);
        }
        
        return updatedPossibleSearchQueries;
    }
    
    
    /**
     Converts a string of edict _ids from the runDictionarySearchQuery or runRomajiSearchQuery methods into the final result set of WordEntries
     
     - parameter database object
     - parameter concatenated string of Edict _ids, comma delimited
     */
    private func createSearchResultWordEntries(myDatabase : FMDatabase ,  idstopasson : String)  {
        var results: FMResultSet!;
        
        let sqlQuery = String(sep:", ",
                              "SELECT [_id] ",
                              ",[Kanji] ",
                              ",[Definition] ",
                              ",[Furigana] ",
                              ",[Common] ",
                              ",KanjiLength ",
                              
                              "FROM ",
                              "( ",
                              "SELECT [_id] ",
                              ",[Kanji] ",
                              ",[Definition] ",
                              ",(CASE WHEN (Furigana is null OR  Furigana = '') then \"\" else \"(\" || Furigana || \")\" end) as [Furigana] ",
                              ",LENGTH(ifnull([Furigana],[Kanji])) as [KanjiLength] ",
                              ",[Common] ",
                              
                              "FROM ",
                              "( ",
                              "SELECT [_id] ",
                              ",[Kanji] ",
                              ",[Furigana] ",
                              ",[Definition] ",
                              ",[Common] ",
                              "FROM [Edict] where [_id] in (\(idstopasson)) ",
                              ") ",
                              ") ORDER BY [Common],[KanjiLength] ");
        
        results = myDatabase.executeQuery(sqlQuery, withArgumentsInArray: nil)
        
        if (results != nil) {
            print("results: \(results.hasAnotherRow())")
            while (results.next()) {
                var wordEntry : WordEntry = WordEntry(_id: Int(results.stringForColumn("_id")));
                wordEntry.kanji = results.stringForColumn("Kanji");
                wordEntry.furigana = results.stringForColumn("Furigana");
                wordEntry.definition = results.stringForColumn("Definition");
                searchResults.append(wordEntry);
            }
            results.close()
        }
        
        
        
        // Attach favorite list information to the word entries in the dictionary results
        if(idstopasson.characters.count > 0){
            
            let favoriteInfoForResultSet : [Int : StarColorData] = getCurrentFavoritesForWordIds(idstopasson, database: myDatabase, colorlistsPrefs: availableWordLists.systemlists);
            
            for i in 0 ..< searchResults.count {
                if(favoriteInfoForResultSet.keys.contains(searchResults[i]._id)) {
                    searchResults[i].favoriteLists = favoriteInfoForResultSet[searchResults[i]._id];
                }
            }
            
        }
        
    }
    
    /**
     Opens the MyListChooserPopover when user long-presses the favorites star next to a search result
     */
    func starlongpress(longPressGesture:UILongPressGestureRecognizer) {
        
        let p = longPressGesture.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(p)
        
        showListChooserPopover(searchResults[indexPath!.row], starOrigin: p, availableWordLists: availableWordLists, rowIndexPath: indexPath!)
    }
    
    
    
    /**
     In order to get the searchview and it's text to scale up for large devices, this method locates the searchbar textView and adjust its
     size manually. Called during layout of searchview and whenever editing searchview text.
     */
    func resetSearchBar() {
        dispatch_async(dispatch_get_main_queue(),
                       
                       {
                        
                        
                        //This code will run in the main thread:
                        for subView in self.searchBar.subviews  {
                            for subsubView in subView.subviews  {
                                if let textField = subsubView as? UITextField {
                                    
                                    var bounds: CGRect
                                    bounds = textField.frame
                                    bounds.size.height = 36 * self.goldenRatio //(set height whatever you want)
                                    textField.bounds = bounds
                                    textField.borderStyle = UITextBorderStyle.RoundedRect
                                    textField.borderStyle = .RoundedRect;
                                    textField.font = UIFont(name: (textField.font!.fontName), size: 17 * self.goldenRatio);
                                    
                                    
                                    
                                    let whatSearchImage : UIImage = UIImage(named: "ic_search")!;
                                    let whatSearchView : UIImageView = UIImageView(frame: CGRectMake(0, 0, 30 * self.goldenRatio, 30 * self.goldenRatio));
                                    
                                    whatSearchView.image = whatSearchImage;
                                    textField.leftViewMode = .Always;
                                    textField.leftView = whatSearchView;
                                    
                                    if(self.clearButton  != nil) {
                                        
                                        textField.rightView = self.clearButton
                                        textField.rightView?.userInteractionEnabled = true;
                                        
                                        
                                        textField.clearButtonMode = UITextFieldViewMode.Never
                                        textField.rightViewMode = UITextFieldViewMode.WhileEditing
                                    }
                                    
                                    
                                    
                                }
                            }
                        }
                        
            }
        )
        
    }
    
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        var longside: CGFloat;
        var shortside: CGFloat;
        if(screenBounds.width > screenBounds.height) {
            longside = screenBounds.width
            shortside = screenBounds.height
        } else {
            longside = screenBounds.height
            shortside = screenBounds.width
        }
        
        
        
        if let navCon = self.navigationController as? Preferences_NavController {
            
            let triggerTime = (Int64(NSEC_PER_MSEC) * 200)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                
                if(toInterfaceOrientation.isLandscape) {
                    navCon.setUpNavigationBar(longside, screenheight: shortside);
                    
                } else {
                    navCon.setUpNavigationBar(shortside, screenheight: longside);
                }
            })
            
            
        }
        
        for constraint in self.view.constraints {
            if(constraint.identifier == "topanchor") {
                constraint.active = false;
                self.view.removeConstraint(constraint)
                
            }
        }
        
        let anchorconstant : CGFloat = 44 * goldenRatio;
        
        let topanchor = topView.topAnchor.constraintEqualToAnchor(topView.superview?.topAnchor, constant: anchorconstant);
        topanchor.identifier = "topanchor";
        topanchor.active = true;
    }
    
    
    /**
     Callback to navigation controller to update the ListController_MyLists VC when words in search results
     have been added/removed from Word Lists (so user can switch to that VC and it will already be updated)
     */
    func tellNavContoUpdateMainViews(changeit: Bool){
        
        if let navcon = self.navigationController as? Preferences_NavController {
            navcon.updatethemanview = changeit;
        }
    }
    
    
    /**
     Adjusts anchors and font sizes in the Search storyboard so that they adhere to the "goldenRatio" parameter. Keeps formatting
     constant as screen size increases/decreases
     */
    private func setFormattingandConstraints(){
        
        ///Dynamically sets the height of the searchBar textview
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    var bounds: CGRect
                    bounds = textField.frame
                    bounds.size.height = 36 * goldenRatio //(set height whatever you want)
                    textField.bounds = bounds
                    textField.borderStyle = UITextBorderStyle.RoundedRect
                }
            }
        }
        
        
        showresultsanchor =  txtNoResults.heightAnchor.constraintEqualToConstant(22 * goldenRatio);
        hideresultsanchor = txtNoResults.heightAnchor.constraintEqualToConstant(0);
        hideresultsanchor.active = true;
        
        
        searchBar.heightAnchor.constraintEqualToConstant(44.0 * goldenRatio).active = true;
        topView.heightAnchor.constraintEqualToConstant(44.0 * goldenRatio).active = true;
        txtSearchOn.leadingAnchor.constraintEqualToAnchor(txtSearchOn.superview?.leadingAnchor, constant: 4.0 * goldenRatio).active = true;
        checkboxRomaji.leadingAnchor.constraintEqualToAnchor(txtSearchOn.trailingAnchor, constant: 4 * goldenRatio).active = true;
        txtRomaji.leadingAnchor.constraintEqualToAnchor(checkboxRomaji.trailingAnchor, constant: 4 * goldenRatio).active = true;
        checkboxDefinition.leadingAnchor.constraintEqualToAnchor(txtRomaji.trailingAnchor, constant: 4 * goldenRatio).active = true;
        txtDefinition.leadingAnchor.constraintEqualToAnchor(checkboxDefinition.trailingAnchor, constant: 4 * goldenRatio).active = true;
        txtSearchOn.heightAnchor.constraintEqualToConstant(44.0 * goldenRatio).active = true;
        txtRomaji.heightAnchor.constraintEqualToConstant(44.0 * goldenRatio).active = true;
        txtDefinition.heightAnchor.constraintEqualToConstant(44.0 * goldenRatio).active = true;
        
        /*** Adjust label size based on size of device, using the "Golden Ratio" **/
        txtSearchOn.font = txtSearchOn.font.fontWithSize(17.0 * goldenRatio)
        txtNoResults.font = txtNoResults.font.fontWithSize(17.0 * goldenRatio)
        txtRomaji.font = txtRomaji.font.fontWithSize(16.0 * goldenRatio);
        txtDefinition.font = txtDefinition.font.fontWithSize(16.0 * goldenRatio);
        
        
        let buttonheight = 24.0 * goldenRatio
        
        checkboxRomaji.frame = CGRectMake(0,0,buttonheight,buttonheight)
        checkboxRomaji.widthAnchor.constraintEqualToConstant(buttonheight).active = true;
        checkboxRomaji.heightAnchor.constraintEqualToConstant(buttonheight).active = true;
        
        checkboxDefinition.frame = CGRectMake(0,0,buttonheight,buttonheight)
        checkboxDefinition.widthAnchor.constraintEqualToConstant(buttonheight).active = true;
        checkboxDefinition.heightAnchor.constraintEqualToConstant(buttonheight).active = true;
        
        
        NSLayoutConstraint(item: checkboxDefinition, attribute: .CenterY, relatedBy: .Equal, toItem: checkboxDefinition.superview, attribute: .CenterY, multiplier: 1, constant: 0).active = true;
        NSLayoutConstraint(item: checkboxRomaji, attribute: .CenterY, relatedBy: .Equal, toItem: checkboxRomaji.superview, attribute: .CenterY, multiplier: 1, constant: 0).active = true;
        
        
        checkboxRomaji.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
        checkboxRomaji.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
        checkboxDefinition.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
        checkboxDefinition.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
    }
    
    
    private func getUserCreatedLists()->[String]{
        
        var userCreatedLists = [String]();
        
        if SQLiteDataStore.sharedInstance.myDatabase.open() {
            
            SQLiteDataStore.attachInternalxDB()
            
            do {
                
                let sqlquerylistcount = "Select DISTINCT Name from JFavoritesLists";
                
                let results:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery(sqlquerylistcount, withArgumentsInArray: nil)
                
                
                if(results != nil) {
                    while (results.next()) {
                        userCreatedLists.append(results.stringForColumn("Name"));
                        
                    }
                    results.close();
                }
                
            }
            
            SQLiteDataStore.sharedInstance.myDatabase.close()
        }
        
        return userCreatedLists;
        
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection)  -> UIModalPresentationStyle {
        return .None
    }
    
    
    /**
     Recieves updated available system lists after user has changed them in
     the preferences fragment, and makes the user search again
     */
    func updatePreferenceFavorites() {
        //Find fav lists that should be removed
        availableWordLists.systemlists = NSUserDefaults.standardUserDefaults().stringArrayForKey("favoritesstarsarray") as [String]!;
        self.txtNoResults.hidden = true;
        self.showresultsanchor.active = true;
        self.hideresultsanchor.active = false;
        self.tableView.hidden = true;
        searchResults = [WordEntry]();
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        // Adjusts top anchor depending on device orientation
        for constraint in self.view.constraints {
            if(constraint.identifier == "topanchor") {
                constraint.active = false;
                self.view.removeConstraint(constraint)
                
            }
        }
        
        let anchorconstant : CGFloat = 44 * goldenRatio;
        let topanchor = topView.topAnchor.constraintEqualToAnchor(topView.superview?.topAnchor, constant: anchorconstant);
        topanchor.identifier = "topanchor";
        topanchor.active = true;
        
    }
    
    
    
    override func viewWillLayoutSubviews() {
        // Scales up searchbar view size (As well as textsize) for larger devices
        if(goldenRatio > 1) {
            resetSearchBar()
        }
    }
    
    
    
}

extension Search_test: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}





