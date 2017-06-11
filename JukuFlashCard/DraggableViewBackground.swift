//
//  DraggableViewBackground.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import Foundation
import UIKit



// Creates the stack of DraggableViews that make up the "Flash Cards" in the FlashCards activity
class DraggableViewBackground: UIView, DraggableViewDelegate {
    
    
    var flashCardLabels: [FlashCardData]!;
    var allCards: [DraggableView]!
    var goldenRatio : CGFloat!;
    
    let MAX_BUFFER_SIZE = 2
    var CARD_HEIGHT: CGFloat!;
    let CARD_WIDTH: CGFloat = 338
    
    var stackpositionindex: Int!; // tracks position in card stack
    var nextcardhasbeencreated: Bool!;
    
    var fronttype : String!;
    var backtype : String!;
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    init(frame: CGRect, flashcardlabels: [FlashCardData], fronttype: String, backtype: String, goldenRatio: CGFloat, cardheight: CGFloat!) {
        super.init(frame: frame)
        super.layoutSubviews()
        self.setupView()
        
        self.fronttype = fronttype
        self.backtype = backtype
        self.flashCardLabels = flashcardlabels;
        self.goldenRatio = goldenRatio;
        self.CARD_HEIGHT = cardheight;
        
        allCards = []
        stackpositionindex = 0;
        nextcardhasbeencreated = false;
        if(self.CARD_HEIGHT == nil) {
            self.CARD_HEIGHT = 450;
        }
        self.loadinitialcards()
    }
    
    func setupView() -> Void {
        self.backgroundColor = UIColor(red: 0.92, green: 0.93, blue: 0.95, alpha: 1)
        
    }
    
    
    /** Creates the "Card" object (DraggableView) that displays the flashcard data, and that the user interacts with.
     The formatting of the text and its constraints change depending in the type of data displayed. Kanji and Kana
     data are shown centered in the view, with a set textsize.  Definitions, if they are longer than one line, are showing
     justified to the left of the view, and the textsize shrinks for larger definitions, so that it all fits on the card
     
     - parameter index: index in dataset of the item that will become a flashcard
     */
    func createDraggableViewWithDataAtIndex(index: NSInteger) -> DraggableView {
        
        var extra = 50 * goldenRatio;
        if(CARD_HEIGHT < 450) {
            extra = 20 * goldenRatio;
        }
        let draggableView = DraggableView(frame: CGRectMake((self.frame.size.width - (CARD_WIDTH * goldenRatio))/2, (self.frame.size.height - (CARD_HEIGHT*goldenRatio))/2 + (extra), CARD_WIDTH * goldenRatio, CARD_HEIGHT * goldenRatio))
        
        draggableView.goldenRatio = goldenRatio;
        draggableView.layer.cornerRadius = 5.0 * goldenRatio
        draggableView.layer.borderColor = UIColor.blackColor().CGColor
        draggableView.layer.borderWidth = 1.0 * goldenRatio
        draggableView.stackView.center = CGPointMake(draggableView.frame.size.width  / 2,
                                                     draggableView.frame.size.height / 2);
        
        print("fronttype: \(fronttype)")
        
        if(fronttype != nil && fronttype == "Definition") {
            let newText : String! = flashCardLabels[index].front;
            
            let splitdef = splitdefinitionbulletpoints_flashcards(newText);
            draggableView.fronttext = splitdef.0
            draggableView.label_main.text = draggableView.fronttext;
            
            if(splitdef.1 == true) {
                draggableView.frontdef = true;
                draggableView.deftextsize = splitdef.2;
                draggableView.label_main.textAlignment = NSTextAlignment.Left;
                draggableView.stackView.alignment = .Leading
                draggableView.label_main.layoutMargins.left = 20 * goldenRatio
                draggableView.stackView.layoutMargins.left = 20  * goldenRatio
                draggableView.label_main.font = draggableView.label_main.font.fontWithSize(CGFloat(splitdef.2))
                
                setconstraints(draggableView, isdefinition: true)
                
            } else {
                draggableView.frontdef = false;
                draggableView.label_main.textAlignment = NSTextAlignment.Center;
                draggableView.stackView.alignment = .Center
                draggableView.label_main.layoutMargins.left = 0
                draggableView.stackView.layoutMargins.left = 0
                draggableView.label_main.font = draggableView.label_main.font.fontWithSize(CGFloat(30 * goldenRatio))
                
                setconstraints(draggableView, isdefinition: false)
            }
            
        } else {
            draggableView.fronttext = flashCardLabels[index].front
            draggableView.label_main.text = flashCardLabels[index].front;
            draggableView.label_main.textAlignment = NSTextAlignment.Center;
            draggableView.label_main.layoutMargins.left = 0;
            draggableView.label_main.font = draggableView.label_main.font.fontWithSize(45 * goldenRatio)
            setconstraints(draggableView, isdefinition: false)
        }
        
        
        if(flashCardLabels[index].furigana != nil) {
            draggableView.furigana = flashCardLabels[index].furigana
        }
        draggableView.backtext = flashCardLabels[index].back
        
        
        
        
        if(backtype != nil && backtype == "Definition") {
            let newText : String! = flashCardLabels[index].back;
            let splitdef = splitdefinitionbulletpoints_flashcards(newText);
            draggableView.backtext = splitdef.0
            
            
            if(splitdef.1 == true) {
                draggableView.backdef = true;
                draggableView.deftextsize = splitdef.2;
            } else {
                draggableView.backdef = false;
            }
            
        } else {
            draggableView.backtext = flashCardLabels[index].back
        }
        
        
        draggableView._id = flashCardLabels[index]._id
        
        let cardcountlabel = UILabel();
        cardcountlabel.clipsToBounds = true
        cardcountlabel.frame = CGRect(x: 10*goldenRatio, y: 05*goldenRatio, width: 60*goldenRatio, height: 60*goldenRatio)
        cardcountlabel.font = cardcountlabel.font.fontWithSize(16*goldenRatio)
        cardcountlabel.text = "\(index+1)/\(flashCardLabels.count)"
        draggableView.addSubview(cardcountlabel)
        draggableView.bringSubviewToFront(cardcountlabel)
        draggableView.label_furigana.text = flashCardLabels[index].furigana
        draggableView.tag = index;
        draggableView.delegate = self
        draggableView.stackView.axis = .Vertical
        draggableView.stackView.distribution = .EqualSpacing
        draggableView.stackView.spacing = 5*goldenRatio
        draggableView.stackView.translatesAutoresizingMaskIntoConstraints = false
        draggableView.label_main.translatesAutoresizingMaskIntoConstraints = false;
        draggableView.label_furigana.translatesAutoresizingMaskIntoConstraints = false;
        
        let views = [
            "stackView" : draggableView.stackView,
            "label_main" : draggableView.label_main,
            "label_furigana" : draggableView.label_furigana,
            "superview" : draggableView
        ]
        
        draggableView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[stackView]-|",
            options: NSLayoutFormatOptions.AlignAllCenterX,
            metrics: nil,
            views: views
            ))
        
        
        draggableView.stackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[label_main]-|",
            options: [],
            metrics: nil,
            views: views
            ))
        draggableView.stackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[label_furigana]-|",
            options: [],
            metrics: nil,
            views: views
            ))
        
        draggableView.stackView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[label_main]-[label_furigana]-|",
            options: [],
            metrics: nil,
            views: views
            ))
        
        return draggableView
    }
    
    
    /**
     Creates a blank card view that stays at the bottom of the view stack, so that when the user is dragging a
     card view the blank card below it is visible, and it appears more like a real stack of cards
     
     */
    func createBlankBottomCard() -> DraggableView {
        
        var extra = 50 * goldenRatio;
        if(CARD_HEIGHT < 450) {
            extra = 20 * goldenRatio;
        }
        let draggableView = DraggableView(frame: CGRectMake((self.frame.size.width - (CARD_WIDTH*goldenRatio))/2, (self.frame.size.height - (goldenRatio*CARD_HEIGHT))/2 + extra, CARD_WIDTH * goldenRatio, CARD_HEIGHT * goldenRatio))
        draggableView.label_main.text = "";
        draggableView.delegate = self
        draggableView.userInteractionEnabled = false;
        return draggableView
    }
    
    func setnextcardtofalse() -> Void {
        nextcardhasbeencreated = false;
    }
    func loadinitialcards() -> Void {
        if(flashCardLabels.count > 0) {
            let newCard: DraggableView = self.createDraggableViewWithDataAtIndex(stackpositionindex);
            newCard.tag = 0;
            let blankcard: DraggableView = self.createBlankBottomCard();
            blankcard.tag = -1;
            allCards.append(newCard)
            allCards.append(blankcard)
            
            self.addSubview(allCards[0]);
            self.insertSubview(allCards[1], belowSubview: allCards[0])
            
        }
        
    }
    
    
    func nextcardalreadycreated() -> Bool {
        return nextcardhasbeencreated;
    }
    
    
    /**
     Adds the next draggableview (flashcard) to the bottom of the deck when user swipes forward
     */
    func cardSwipedForward(card: UIView) -> Void {
        
        if(stackpositionindex < (flashCardLabels.count - 1 )) {
            stackpositionindex = stackpositionindex + 1;
            
            self.insertSubview(self.createDraggableViewWithDataAtIndex(stackpositionindex), aboveSubview: allCards[1]);
            
            nextcardhasbeencreated = true;
        }
        
    }
    
    /**
     Checks if there is another card available in the flashcard deck below the current card
     
     return - bool true if another card exists, false if not
     */
    func isThereAnotherCardBelow() -> Bool {
        
        var isthere = false;
        if(self.subviews.count > 2) {
            isthere = true;
        }
        
        return isthere;
    }
    
    /**
     When user changes swiping direction, this removes any on-deck cards below the current visible card, so
     that the currect set of on-deck cards can be added
     
     There is basically an imaginary "deck" of cards below the current visible card. Each time
     the user changes directions in the deck, a new set of "on-deck" cards must be created below the visible card.
     If user goes forward, the on deck cards must be cards following the visible card. If user goes backward, on-deck cards
     must be previous cards to the current one, so that when they swipe, the correct following/preceding card will appear
     
     - parameter card: current draggable flashcard view
     - parameter fromabove: bool true if the user is cycling backwards through the deck, false if forwards
     */
    func undonextcard(card: UIView, fromabove : Bool) -> Void {
        
        if(self.subviews.count>2) {
            self.viewWithTag(stackpositionindex)?.removeFromSuperview();
            if(fromabove == true) {
                stackpositionindex = stackpositionindex - 1;
            } else {
                stackpositionindex = stackpositionindex + 1;
                
            }
            
            nextcardhasbeencreated = false;
            
        }
        
    }
    
    /**
     Adds the next draggableview (flashcard) to the bottom of the deck when user swipes backward
     
     - parameter card: current flashcard being swiped
     */
    func cardSwipedBackward(card: UIView) -> Void {
        
        if(stackpositionindex > 0) {
            stackpositionindex = stackpositionindex - 1;
            self.insertSubview(self.createDraggableViewWithDataAtIndex(stackpositionindex), aboveSubview: allCards[1]);
            nextcardhasbeencreated = true;
        }
        
        
    }
    
    
    /**
     Takes a single definition string of unknown length, with unknown number of sub-definitions (demarketed with parenthesis like: "(1)" or "(2)")
     and splits them out into bullet point rows, while also shrinking the textsize so the definition will fit in the card
     
     - parameter oldText: flashcard definition string to be broken up
     */
    func splitdefinitionbulletpoints_flashcards(oldText: String)-> (String, Bool,Int) {
        
        
        var justifyleftofcenter = false;
        var stringBuilder = "";
        
        let suggestedtextsize = 30 * goldenRatio;
        let testlabel  = UILabel(frame: CGRectMake(0, 50 * goldenRatio, self.frame.size.width, 100*goldenRatio))
        testlabel.text = "";
        testlabel.textAlignment = NSTextAlignment.Center
        testlabel.textColor = UIColor.blackColor()
        testlabel.font = testlabel.font.fontWithSize(CGFloat(suggestedtextsize))
        testlabel.adjustsFontSizeToFitWidth = true
        testlabel.numberOfLines = 0;
        testlabel.minimumScaleFactor = 0.5 //this is the mini
        var new_suggestedtextsize = suggestedtextsize;
        var stopaddingdefinitions : Bool = false;
        
        for i in 1 ..< 8 {
            
            let s = "(\(i))";
            let sNext = "(\(i+1))";
            let slength = s.characters.count;
            
            var newText = oldText;
            if (newText.contains(s) && stopaddingdefinitions == false) {
                let indexofs = newText.indexOf(s);
                var endIndex = newText.endIndex;
                if (newText.contains(sNext)) { //If we can find the next "(#)" in the string, we'll use it as this definition's end point
                    endIndex = newText.indexOf(sNext)!;
                }
                
                var sentence = newText.substringWithRange(Range<String.Index>((indexofs?.advancedBy(slength))! ..< endIndex));
                
                //Capitalize first letter
                if (sentence.characters.count > 1) {
                    sentence.replaceRange(sentence.startIndex...sentence.startIndex, with: String(sentence[sentence.startIndex]).capitalizedString)
                }
                
                var newstring = stringBuilder;
                newstring.appendContentsOf("• \(sentence) \n")
                
                
                testlabel.text = newstring;
                testlabel.font = testlabel.font.fontWithSize(CGFloat(new_suggestedtextsize))
                
                let requiredHeight = Double(testlabel.requiredHeight());
                let availableHeight = Double(CARD_HEIGHT * goldenRatio) * 0.7
                
                if(requiredHeight >  availableHeight) {
                    
                    var new_requiredHeight = Int(requiredHeight)
                    
                    while(new_requiredHeight > Int(availableHeight) && new_suggestedtextsize > (18*goldenRatio)) {
                        if(new_suggestedtextsize > (18*goldenRatio)) {
                            new_suggestedtextsize = new_suggestedtextsize - 2;
                        }
                        
                        testlabel.font = testlabel.font.fontWithSize(CGFloat(new_suggestedtextsize))
                        new_requiredHeight = Int(testlabel.requiredHeight());
                    }
                    
                    //If it's as shrunk as can be
                    if(new_requiredHeight > Int(availableHeight) ) {
                        stopaddingdefinitions = true;
                    } else {
                        stringBuilder.appendContentsOf("• \(sentence) \n");
                        justifyleftofcenter = true;
                    }
                    
                }  else {
                    
                    
                    stringBuilder.appendContentsOf("• \(sentence) \n");
                    justifyleftofcenter = true;
                }
                
                
            } else if (i == 1) { //if the thing doesn't contain a "(1)", just print the whole definition in line 1 of the array.
                newText.replaceRange(newText.startIndex...newText.startIndex, with: String(newText[newText.startIndex]).capitalizedString)
                stringBuilder.appendContentsOf(newText);
            }
            
        }
        
        
        
        return (stringBuilder, justifyleftofcenter, Int(new_suggestedtextsize))
    }
    
    
    /**
     Card constraints change depending on the contents of the card (definition is justified left, kanji/kana is centered)
     
     - parameter draggableView: draggable flashcard
     - parameter isdefinition: bool true if the card is showing a definition, false if not
     */
    func setconstraints(draggableView: DraggableView,isdefinition: Bool) {
        
        for constraint in draggableView.constraints {
            if(constraint.identifier == "constraint") {
                constraint.active = false;
                draggableView.removeConstraint(constraint);
                
            }
        }
        
        if(isdefinition) {
            let vertconstraint_top = draggableView.stackView.topAnchor.constraintEqualToAnchor(draggableView.topAnchor, constant: 30 * goldenRatio);
            vertconstraint_top.identifier = "constraint";
            vertconstraint_top.active = true;
            draggableView.addConstraint(vertconstraint_top)
            
            let vertconstraint_bottom = draggableView.stackView.bottomAnchor.constraintEqualToAnchor(draggableView.bottomAnchor);
            vertconstraint_bottom.identifier = "constraint";
            
            vertconstraint_bottom.active = true;
            draggableView.addConstraint(vertconstraint_bottom)
            
            
            
        } else {
            let vertconstraint =  NSLayoutConstraint(item: draggableView.stackView, attribute: .CenterY, relatedBy: .Equal, toItem: draggableView.stackView.superview, attribute: .CenterY, multiplier: 1, constant: 0)
            vertconstraint.identifier = "constraint";
            vertconstraint.active = true;
            draggableView.addConstraint(vertconstraint)
        }
    }
    
    
}