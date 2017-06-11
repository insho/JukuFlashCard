//
//  MenuPopover_FlashCards.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit


/** Popover appearing when user clicks on "FlashCards" for a list, allowing them to choose
 options for the flashcards before beginning the activity */
class MenuPopover_FlashCards: UIViewController, UIPopoverPresentationControllerDelegate , ListController_DropDownSelectedDelegate {
    
    var jlptdelegate : MenuPopoverFlashCardsDelegate!;
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds)
    
    @IBOutlet weak var txtOKButton: UIButton!
    @IBOutlet weak var txtCancelButton: UIButton!
    @IBOutlet weak var txtfrontlabel: UILabel!
    @IBOutlet weak var txtbacklabel: UILabel!
    @IBOutlet weak var txtheader: UILabel!
    @IBAction func buttonCancel(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Sends a package with the specified details that the user has chosen for the flashcard quiz back to ListController_MyLists which segues to FlashCards VC
    @IBAction func buttonOK(sender: UIButton) {
        
        let package = MenuPopoverToSeguePackage(frontvalue: (txtbuttonFront.titleLabel?.text)!, backvalue: (txtbuttonBack.titleLabel?.text)!, currentMyList: currentMyList)
        jlptdelegate?.seguetoactivity(package)
    }
    
    
    
    @IBOutlet weak var txtbuttonFront: UIButton!
    @IBOutlet weak var txtbuttonBack: UIButton!
    @IBAction func buttonFront(sender: UIButton) {
        
        showDropdownPopup(sender, optionArray: ["Kanji","Kana","Definition"], buttonCategory: "Front")
        
    }
    
    @IBAction func buttonBack(sender: UIButton) {
        showDropdownPopup(sender, optionArray: ["Kanji","Kana","Definition"], buttonCategory: "Back")
    }
    
    var currentMyList : MyListEntry!;
    let ismenupopover = false;
    
    
    /**
     Displays a dropdown menu below a "button" in the MenuPopover with the various selectable options for that item
     
     - parameter sender: button below which the dropdown popup will appear
     - parameter optionArray: flashcard options that can be selected for that item
     - parameter buttonCategory: type of flashcard category that is being changed -- "front", "back" etc
     
     */
    func showDropdownPopup(sender: UIButton, optionArray: [String], buttonCategory: String) {
        
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("dropdownPopover") as! ListController_DropDown
        popController.modalPresentationStyle = UIModalPresentationStyle.Popover
        let dropdownarray:Array = optionArray;
        let prefheight : CGFloat = CGFloat(dropdownarray.count) * 26.0 * goldenRatio
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = sender // button
        popController.preferredContentSize = CGSize(width: Int(sender.frame.width), height: Int(prefheight))
        
        popController.popoverPresentationController?.sourceRect = CGRectMake(CGFloat(CGRectGetMidX(sender.bounds)) , CGFloat(CGRectGetMaxY(sender.bounds) + 8.0 * goldenRatio + prefheight/2.0),0,0)
        popController.mDelegate = self
        popController.initialdropArray = dropdownarray;
        popController.initialdropCategory = buttonCategory;
        popController.idkey = -1;
        popController.spinnertag = -1;
        popController.goldenratio = goldenRatio;
        
        self.presentViewController(popController, animated: true, completion: nil)
        
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /*** DEVICE-SIZE FORMATTING ***/
        
        txtheader.font = txtheader.font.fontWithSize(20*goldenRatio)
        txtfrontlabel.font = txtfrontlabel.font.fontWithSize(17*goldenRatio)
        txtbacklabel.font = txtbacklabel.font.fontWithSize(17*goldenRatio)
        txtCancelButton.titleLabel!.font = txtCancelButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtOKButton.titleLabel!.font = txtOKButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtbuttonFront.titleLabel!.font = txtbuttonFront.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtbuttonBack.titleLabel!.font = txtbuttonBack.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtheader.heightAnchor.constraintEqualToConstant(50*goldenRatio).active = true;
        txtbuttonFront.frame.size = CGSizeMake(200*goldenRatio, txtbuttonFront.frame.size.height)
        txtbuttonBack.frame.size = CGSizeMake(200*goldenRatio, txtbuttonBack.frame.size.height)
        txtbuttonFront.widthAnchor.constraintEqualToConstant(200*goldenRatio).active = true;
        txtbuttonBack.widthAnchor.constraintEqualToConstant(200*goldenRatio).active = true;
        
        
        if(goldenRatio >= 1) {
            txtfrontlabel.topAnchor.constraintEqualToAnchor(txtheader.bottomAnchor, constant: 20*goldenRatio).active = true;
            txtbuttonFront.topAnchor.constraintEqualToAnchor(txtheader.bottomAnchor, constant: 20*goldenRatio).active = true;
            txtbacklabel.topAnchor.constraintEqualToAnchor(txtfrontlabel.bottomAnchor, constant: 10*goldenRatio).active = true;
            txtbuttonBack.topAnchor.constraintEqualToAnchor(txtbuttonFront.bottomAnchor, constant: 10*goldenRatio).active = true;
            txtbuttonBack.leadingAnchor.constraintEqualToAnchor(txtbacklabel.trailingAnchor, constant: 20*goldenRatio).active = true;
        } else {
            txtfrontlabel.topAnchor.constraintEqualToAnchor(txtheader.bottomAnchor, constant: 20*goldenRatio).active = true;
            txtbuttonFront.topAnchor.constraintEqualToAnchor(txtheader.bottomAnchor, constant: 20*goldenRatio).active = true;
            txtbuttonFront.leadingAnchor.constraintEqualToAnchor(txtfrontlabel.trailingAnchor, constant: 10*goldenRatio).active = true;
            txtbacklabel.topAnchor.constraintGreaterThanOrEqualToAnchor(txtfrontlabel.bottomAnchor).active = true;
            txtbacklabel.topAnchor.constraintEqualToAnchor(txtheader.bottomAnchor, constant: 60*goldenRatio).active = true;
            txtbuttonBack.leadingAnchor.constraintEqualToAnchor(txtbacklabel.trailingAnchor, constant: 10*goldenRatio).active = true;
        }
        
        txtOKButton.trailingAnchor.constraintEqualToAnchor(txtOKButton.superview?.trailingAnchor, constant: -(20 * goldenRatio)).active = true;
        txtCancelButton.trailingAnchor.constraintEqualToAnchor(txtCancelButton.superview?.trailingAnchor, constant:-(50.0 * goldenRatio + txtOKButton.frame.size.width)).active = true;
        
        self.view.layer.cornerRadius = 08.0 * goldenRatio
        self.view.layer.borderWidth = 0.5 * goldenRatio
        self.view.layer.borderColor = UIColor.blackColor().CGColor
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection)  -> UIModalPresentationStyle {
        return .None
    }
    
    func optionSelected(dropDownCategory: String, optionName: String){
        switch dropDownCategory {
        case "Front":
            txtbuttonFront.setTitle(optionName, forState: .Normal)
        case "Back":
            txtbuttonBack.setTitle(optionName, forState: .Normal)
        default:
            break;
        }
    }
    
    
}
