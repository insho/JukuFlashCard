//
//  FlashCards.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit


/** Shows "Flashcards" (i.e. draggable views) for a dataset of FlashCardData objects. User can navigate
 through the stack by swiping back and forth. Double tap to see other side of card. Single tap
 to show furigana (if the current card face is displayig a kanji). Dataset can be shuffled
 by pressing the floating action button.
 */
class FlashCards: UIViewController {
    
    let interactor = Interactor()
    var currentMyList : MyListEntry!;
    var mDataSet = [FlashCardData]();
    var currentPosition : Int!;
    var flipped : Bool!;  //whether or not the card is flipped to the back side (true), or not (false)
    var totalcount : Int!; //total count of cards in stack
    var currentcount : Int! = 1; //current position count in stack
    var frontValue : String!;
    var backValue : String!;
    
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds);
    
    
    //Pull dataset for the current word list
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if SQLiteDataStore.sharedInstance.myDatabase.open() {
            
            SQLiteDataStore.attachInternalxDB()
            
            let sqlqueryPullFlashCardData = String(sep:", ",
                                                   
                                                   "SELECT DISTINCT [_id] ",
                                                   ",[Kanji] ",
                                                   ",[Furigana] ",
                                                   ",[Definition] ",
                                                   "FROM [Edict] ",
                                                   "WHERE [_id] in ( ",
                                                   "SELECT [_id] ",
                                                   "FROM [JFavorites] ",
                                                   "WHERE ([Sys] = \(currentMyList.sys) and [Name] = '\(currentMyList.name)') ",
                                                   ") ",
                                                   "ORDER BY [_id]");
            
            
            let results:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery(sqlqueryPullFlashCardData,
                                                                                              withArgumentsInArray: nil)
            
            
            var frontstring = "Kanji"
            var backstring = "Definition"
            
            if(frontValue != nil) {
                if(frontValue == "Kana") {
                    frontstring = "Furigana"
                } else {
                    frontstring = frontValue;
                }
                
            }
            
            if(backValue != nil) {
                if(backValue == "Kana") {
                    backstring = "Furigana"
                } else {
                    backstring = backValue;
                }
                
            }
            
            
            if (results != nil) {
                while (results.next()) {
                    var frontresult = results.stringForColumn(frontstring);
                    var backresult = results.stringForColumn(backstring);
                    
                    
                    if(frontValue == "Kana" && (frontresult == nil || frontresult.characters.count == 0)) {
                        frontresult = results.stringForColumn("Kanji");
                    }
                    
                    if(backValue == "Kana" && (backresult == nil || backresult.characters.count == 0)) {
                        backresult = results.stringForColumn("Kanji");
                    }
                    
                    
                    let flashcard = FlashCardData(_id: Int(results.intForColumn("_id")),front: frontresult, back: backresult, furigana: results.stringForColumn("Furigana"))
                    
                    mDataSet.append(flashcard)
                    
                    
                }
                
                results.close()
                
                
                var card_height : CGFloat;
                let screenbounds = UIScreen.mainScreen().bounds;
                if(screenbounds.size.width > screenbounds.size.height) {
                    card_height = 350;
                } else {
                    card_height = 450;
                }
                
                let draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: self.view.frame, flashcardlabels: mDataSet, fronttype: frontValue, backtype: backValue, goldenRatio: goldenRatio, cardheight: card_height);
                
                self.view.addSubview(draggableBackground)
                settheshufflebutton();
            }
            
            SQLiteDataStore.sharedInstance.myDatabase.close()
        }
        
        
        
        
    }
    
    
    /**
     Adds shuffle button to view
     */
    func settheshufflebutton(){
        let screenBounds = UIScreen.mainScreen().bounds
        
        let shufflebutton = UIButton(type: .Custom)
        
        shufflebutton.backgroundColor = UIColor(hex: 0x2196F3)
        shufflebutton.frame = CGRect(x: (screenBounds.width - (80 * goldenRatio)), y: (80 * goldenRatio), width: (60 * goldenRatio), height: (60 * goldenRatio))
        shufflebutton.layer.cornerRadius = 0.5 * shufflebutton.bounds.size.width
        shufflebutton.clipsToBounds = true
        shufflebutton.setImage(UIImage(named:"ic_shuffle_white"), forState: .Normal)
        shufflebutton.addTarget(self, action: #selector(shufflecards), forControlEvents: .TouchUpInside)
        view.addSubview(shufflebutton)
        
        self.view.bringSubviewToFront(shufflebutton)
    }
    
    
    /**
     Mimick a "shuffle" of the cards by shuffling the dataset and resetting the draggable views
     */
    func shufflecards(){
        
        for subview in view.subviews {
            subview.removeFromSuperview()
        }
        
        
        if(mDataSet.count > 0) {
            let newflashcardArray = mDataSet.shuffle()
            mDataSet = newflashcardArray;
            
            var card_height : CGFloat;
            let screenbounds = UIScreen.mainScreen().bounds;
            if(screenbounds.size.width > screenbounds.size.height) {
                card_height = 350;
            } else {
                card_height = 450;
            }
            
            let draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: self.view.frame, flashcardlabels: mDataSet, fronttype: frontValue, backtype: backValue, goldenRatio: goldenRatio, cardheight: card_height);
            self.view.addSubview(draggableBackground)
            settheshufflebutton()
        }
    }
    
    
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        var longside: CGFloat;
        var shortside: CGFloat;
        if(self.view.frame.width > self.view.frame.height) {
            longside = self.view.frame.width
            shortside = self.view.frame.height
        } else {
            longside = self.view.frame.height
            shortside = self.view.frame.width
        }
        
        
        let triggerTime = (Int64(NSEC_PER_MSEC) * 200)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            
            for subview in self.view.subviews {
                subview.removeFromSuperview()
            }
            
            var updatedFrame : CGRect;
            var card_height : CGFloat;
            
            if(toInterfaceOrientation.isLandscape) {
                updatedFrame = CGRectMake(0, 0, longside, shortside);
                card_height = 350;
            } else {
                updatedFrame = CGRectMake(0, 0, shortside,longside);
                card_height = 450;
            }
            let draggableBackground: DraggableViewBackground = DraggableViewBackground(frame: updatedFrame, flashcardlabels: self.mDataSet, fronttype: self.frontValue, backtype: self.backValue, goldenRatio: self.goldenRatio, cardheight: card_height);
            draggableBackground.CARD_HEIGHT = card_height;
            self.view.addSubview(draggableBackground);
            self.settheshufflebutton();
        })
        
        
    }
    
}


extension FlashCards: UIViewControllerTransitioningDelegate {
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return DismissAnimator()
    }
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}