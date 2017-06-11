
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit


/**
 Custom cell displaying a single word from the Edict dictionary. Used in Search VC.
 */
class customTableViewCell_BrowseItem: UITableViewCell , UIPopoverPresentationControllerDelegate  {
    
    
    @IBOutlet weak var star: UIButton!
    @IBOutlet weak var cellKanji: UILabel!
    @IBOutlet weak var cellDefinition: UILabel!
    
    weak var mCellDelegate: customCell_ListChooserDelegate?
    
    var availableWordLists : StarColorData?;
    var wordEntry : WordEntry?;
    var rowIndexPath : NSIndexPath?;
    var starOrigin : CGPoint!;
    
    
    /**
     Handles what happens when the user presses the favorites star for the row. A few things can happen:
     1. The WordEntry is not associated with any favorites lists (the star is black). On the click, if there are "system favorite lists" available
     (the colored star lists in the WordLists VC), the word will be added to the first favorite list in "availableWordLists.systemlists", and the favorite star will change to the color
     of the list.
     2. The WordEntry is associated with exactly one system favorite list (the star is tinted a primary color). On the click, if there is another system favorite list
     after the current list in "availableWordLists.systemlists" array, assign the word to the next favorite list in the db, and update the favorite star color to reflect the new list. If
     the star is currently assigned the last list in "availableWordLists.systemlists", remove it completely from the favorite list table in the db and make the star black. Basically allows
     for a toggle from Black -> favorite list "red" --> favorite list "blue" etc --> Black
     3. If the WordEntry is associated with more than one favorite list (the star is multi-colored), it should NOT toggle on click, and instead open up the "MyListChooser" popover,
     the same as if the star was long-clicked. User can add/remove the wordentry from multiple lists in the popover, and the star color will be updated on popover dismiss
     4. If the WordEntry is associated with one or more user-created lists and NO system lists, the MyListChooser popover will open like in #3, but the star color will be black instead
     of multi-color
     5. If the WordEntry is associated with exactly one favorite list and one or more user-created lists, the action will be the same as #3 and #4, but the star color will be tinted the color of the favorite list
     */
    @IBAction func starpressed(sender: UIButton) {
        
        // Make sure there are lists to choose from
        if(availableWordLists != nil && availableWordLists!.getTotalWordListCount() > 0 ) {
            
            // If there are multiple lists, open the chooser
            if(wordEntry!.favoriteLists.shouldOpenListPopoverOnClick()) {
                mCellDelegate?.showListChooserPopover(wordEntry!, starOrigin: nil, availableWordLists: availableWordLists!, rowIndexPath: rowIndexPath!);
            } else {
                
                var currentsystemlist : String;
                if(wordEntry!.favoriteLists.systemlists.count>0) {
                    currentsystemlist = wordEntry!.favoriteLists.systemlists[0];
                } else {
                    currentsystemlist = "Black";
                }
                
                
                wordEntry!.favoriteLists.systemlists = [String]();
                
                var newsystemlist = "Black";
                
                // If there is already a system list chosen, delete it
                SQLiteDataStore.deleteWordsFromFavorites(MyListEntry(name: currentsystemlist, sys: 1, checkedstatus: 1, idstoaddorremove: String(wordEntry!._id)));
                
                
                /** Now determine the new star color and selected list, and update the db/star accordingly.
                 If there is at least one more system list above the current one, switch to it */
                if(availableWordLists!.systemlists.contains(currentsystemlist) && (availableWordLists!.systemlists.count-1) > availableWordLists!.systemlists.indexOf(currentsystemlist)!) {
                    
                    newsystemlist = availableWordLists!.systemlists[availableWordLists!.systemlists.indexOf(currentsystemlist)!+1];
                    
                } else if(availableWordLists!.systemlists.contains(currentsystemlist) ) {
                    newsystemlist = "Black"
                    
                } else {
                    newsystemlist = availableWordLists!.systemlists[0];
                }
                
                
                print("NEW SYSTEM LIST: \(newsystemlist)");
                if(newsystemlist != "Black") {
                    SQLiteDataStore.insertWordsIntoFavorites(MyListEntry(name: newsystemlist, sys: 1, checkedstatus: 1, idstoaddorremove: String(wordEntry!._id)));
                    wordEntry!.favoriteLists.systemlists.append(newsystemlist);
                }
                
                switch newsystemlist {
                case "Blue":
                    star.tintColor = UIColor.blueColor()
                case "Green":
                    star.tintColor = UIColor.greenColor()
                case "Red":
                    star.tintColor = UIColor.redColor()
                case "Yellow":
                    star.tintColor = UIColor.yellowColor()
                default:
                    star.tintColor = UIColor.blackColor()
                }
                
            }
            
            mCellDelegate?.retrieveUpdatedFavorites((rowIndexPath?.row)!, updatedFavorites: wordEntry!.favoriteLists!)
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func prepareForReuse() {
        super.selected = false;
        star.hidden = false;
        star.setImage(UIImage(named: "ic_star_black")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        star.tintColor = .None
        cellKanji.text = "";
        cellDefinition.text = "";
        super.backgroundColor = UIColor.clearColor();
    }
    
}