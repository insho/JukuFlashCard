//
//  DraggableView.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import Foundation
import UIKit

let ACTION_MARGIN: Float = 120      //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
let CREATE_SUBVIEW_MARGIN: Float = 40
let DESTROY_CURRENT_VIEW_MARGIN: Float = 120
let SCALE_STRENGTH: Float = 4       //%%% how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX:Float = 0.93          //%%% upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX: Float = 1         //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH: Float = 320  //%%% strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE: Float = 3.14/8  //%%% Higher = stronger rotation angle


//Draggle "card" view that makes up a single flash card in a deck of the FlashCard VC
class DraggableView: UIView, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate {
    var delegate: DraggableViewDelegate!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var originPoint: CGPoint!
    var label_main: UILabel!
    var label_furigana: UILabel!
    var stackView: UIStackView!
    var frontshowing: Bool!
    var fronttext: String!
    var furigana: String!
    var backtext: String!
    var cardnumber: String!
    var goldenRatio: CGFloat!;
    var frontdef = false;
    var backdef = false;
    var deftextsize = 30;
    var _id : Int!;
    
    var xFromCenter: Float!
    var yFromCenter: Float!
    
    var hasbeenMovedRight : Bool!;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if(goldenRatio == nil) {
            goldenRatio = UIScreen.mainScreen().bounds.height / 736 // Mult ratio to get
        }
        
        self.setupView()
        
        fronttext = "";
        furigana = "";
        backtext = "";
        cardnumber = "";
        
        label_main = UILabel(frame: CGRectMake(0, 50 * goldenRatio, self.frame.size.width, 100 * goldenRatio))
        label_main.text = fronttext;
        label_main.textAlignment = NSTextAlignment.Center
        label_main.textColor = UIColor.blackColor()
        label_main.font = label_main.font.fontWithSize(30 * goldenRatio)
        label_main.adjustsFontSizeToFitWidth = true
        label_main.numberOfLines = 0;
        label_main.minimumScaleFactor = 0.5 //this is the mini
        
        label_furigana = UILabel(frame: CGRectMake(0, 50 * goldenRatio, self.frame.size.width, 100 * goldenRatio))
        label_furigana.text = furigana;
        label_furigana.textAlignment = NSTextAlignment.Center
        label_furigana.textColor = UIColor.blackColor()
        label_furigana.font = label_furigana.font.fontWithSize(18 * goldenRatio)
        label_furigana.hidden = true;
        
        stackView = UIStackView();
        stackView.addSubview(label_main)
        stackView.addSubview(label_furigana)
        
        self.backgroundColor = UIColor.whiteColor()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DraggableView.beingDragged(_:)))
        
        self.addGestureRecognizer(panGestureRecognizer)
        self.addSubview(stackView)
        frontshowing = true;
        
        
        let doubletap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubletap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubletap)
        
        let singletap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singletap.numberOfTapsRequired = 1
        singletap.requireGestureRecognizerToFail(doubletap)
        stackView.addGestureRecognizer(singletap)
        
        xFromCenter = 0
        yFromCenter = 0
    }
    
    //Double tap on the card shows the opposite side item. Formatting changes if opposite side item is a definition (justified left).
    func doubleTapped() {
        if(frontshowing == true) {
            
            //Switch to back
            label_main.text = backtext;
            label_furigana.text = "";
            frontshowing = false;
            
            if(backdef == true) {
                label_main.textAlignment = NSTextAlignment.Left;
                stackView.alignment = .Leading
                label_main.layoutMargins.left = 20 * goldenRatio
                stackView.layoutMargins.left = 20 * goldenRatio
                label_main.font = label_main.font.fontWithSize(CGFloat(deftextsize))
                delegate?.setconstraints(self, isdefinition: true)
            } else {
                label_main.textAlignment = NSTextAlignment.Center;
                stackView.alignment = .Center
                
                label_main.layoutMargins.left = 0
                stackView.layoutMargins.left = 0
                label_main.font = label_main.font.fontWithSize(CGFloat(45) * goldenRatio)
                delegate?.setconstraints(self, isdefinition: false)
            }
            
        } else {
            //Switch to front
            label_main.text = fronttext;
            label_furigana.text = furigana;
            frontshowing = true;
            
            if(frontdef == true) {
                label_main.textAlignment = NSTextAlignment.Left;
                stackView.alignment = .Leading
                label_main.layoutMargins.left = 20 * goldenRatio
                stackView.layoutMargins.left = 20 * goldenRatio
                label_main.font = label_main.font.fontWithSize(CGFloat(deftextsize))
                delegate?.setconstraints(self, isdefinition: true)
            } else {
                label_main.textAlignment = NSTextAlignment.Center;
                stackView.alignment = .Center
                label_main.layoutMargins.left = 0
                stackView.layoutMargins.left = 0
                label_main.font = label_main.font.fontWithSize(CGFloat(45) * goldenRatio)
                delegate?.setconstraints(self, isdefinition: false)
            }
        }
    }
    
    // Single tap shows furigana for a kanji (and nothing for a definition)
    func singleTapped() {
        if(label_furigana.hidden == true) {
            label_furigana.hidden = false;
        } else {
            label_furigana.hidden = true;
        }
        
    }
    
    
    
    func setupView() -> Void {
        self.layer.cornerRadius = 4 * goldenRatio;
        self.layer.shadowRadius = 3 * goldenRatio;
        self.layer.shadowOpacity = 0.2 * Float(goldenRatio);
        self.layer.shadowOffset = CGSizeMake(1 * goldenRatio, 1 * goldenRatio);
    }
    
    
    
    func beingDragged(gestureRecognizer: UIPanGestureRecognizer) -> Void {
        xFromCenter = Float(gestureRecognizer.translationInView(self).x)
        yFromCenter = Float(gestureRecognizer.translationInView(self).y)
        
        
        switch gestureRecognizer.state {
        case UIGestureRecognizerState.Began:
            self.originPoint = self.center
            
            print("began")
        case UIGestureRecognizerState.Changed:
            
            if(xFromCenter < -CREATE_SUBVIEW_MARGIN) {
                if(delegate.nextcardalreadycreated() == false) {
                    //Create the next card and put it below the current one
                    delegate.cardSwipedForward(self)
                    hasbeenMovedRight = true;
                    print("cardswipedforward")
                }
            }
            
            if(xFromCenter > CREATE_SUBVIEW_MARGIN) {
                if(delegate.nextcardalreadycreated() == false) {
                    //Create the prev card and put it below the main one
                    delegate.cardSwipedBackward(self)
                    hasbeenMovedRight = false;
                    
                    print("cardswipedbackward")
                    
                }
            }
            
            let rotationStrength: Float = min(xFromCenter/ROTATION_STRENGTH, ROTATION_MAX)
            let rotationAngle = ROTATION_ANGLE * rotationStrength
            
            self.center = CGPointMake(self.originPoint.x + CGFloat(xFromCenter), self.originPoint.y + CGFloat(yFromCenter))
            self.rotate(CGFloat(rotationAngle))
            
            
        case UIGestureRecognizerState.Ended:
            self.rotate(0)
            self.afterSwipeAction(hasbeenMovedRight)
        case UIGestureRecognizerState.Possible:
            print("Possible")
            fallthrough
        case UIGestureRecognizerState.Cancelled:
            print("Canceled")
            
            fallthrough
        case UIGestureRecognizerState.Failed:
            print("Failed")
            fallthrough
        default:
            break
        }
    }
    
    /**
     When swipe is finished, shows next card if swipe has moved the current card far enough to the right/left
     - parameter hasbeenmovedright: bool true if the card was moving to the right (Forward in the deck), false if left
     */
    func afterSwipeAction(hasbeenmovedright : Bool!) -> Void {
        let floatXFromCenter = Float(xFromCenter)
        
        if floatXFromCenter > ACTION_MARGIN {
            if(delegate.isThereAnotherCardBelow() == true) {
                
                if(delegate.nextcardalreadycreated() == true) {
                    self.removeFromSuperview();
                    delegate.setnextcardtofalse();
                }
            } else {
                self.returntheview();
            }
        } else if floatXFromCenter < -ACTION_MARGIN {
            
            if(delegate.isThereAnotherCardBelow() == true) {
                if(delegate.nextcardalreadycreated() == true) {
                    self.removeFromSuperview();
                    delegate.setnextcardtofalse();
                }
                
            } else {
                print("WERE IN B")
                self.returntheview()
            }
        } else {
            
            if(hasbeenmovedright != nil) {
                delegate.undonextcard(self, fromabove: hasbeenmovedright)
            }
            
            self.returntheview()
        }
    }
    
    func returntheview() -> Void {
        UIView.animateWithDuration(0.1, animations: {() -> Void in
            self.center = self.originPoint
            self.transform = CGAffineTransformMakeRotation(0)
        })
    }
    
    //Animate card sliding right
    func rightAction() -> Void {
        
        let finishPoint: CGPoint = CGPointMake(500 * goldenRatio, 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animateWithDuration(0.1,
                                   animations: {
                                    self.center = finishPoint
            }, completion: {
                (value: Bool) in
                
                self.removeFromSuperview()
                
        })
        
    }
    
    //Animate card sliding left
    func leftAction() -> Void {
        
        
        let finishPoint: CGPoint = CGPointMake(-500 * goldenRatio, 2 * CGFloat(yFromCenter) + self.originPoint.y)
        UIView.animateWithDuration(0.1,
                                   animations: {
                                    self.center = finishPoint
            }, completion: {
                (value: Bool) in
                
                self.removeFromSuperview()
        })
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
}