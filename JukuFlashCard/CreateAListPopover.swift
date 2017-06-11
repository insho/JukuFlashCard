//
//  CreateAListPopover.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit



class CreateAListPopover: UIViewController, UITextFieldDelegate {
    
    var delegate: CreateAListDelegate!
    var availableWordLists: StarColorData!;
    var renamelist : Bool!;
    var oldname : String!;
    var header : String!;
    
    
    @IBOutlet weak var txtCancelButton: UIButton!
    @IBOutlet weak var txtOKButton: UIButton!
    @IBOutlet weak var textfield: UITextField!
    
    @IBAction func textfieldChanged(sender: AnyObject) {
        warninglabel.text = "";
    }
    
    @IBOutlet weak var chooseaname: UILabel!
    @IBOutlet weak var warninglabel: UILabel!
    
    @IBAction func textfieldFinished(sender: AnyObject) {
        print("ENTERED TEXT")
        textfield.text = sender.text;
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        //            delegate?.dismissthepopover();
        dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    @IBAction func okButtonPressed(sender: AnyObject) {
        self.view.endEditing(true)
        let newlistname = textfield.text!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        warninglabel.hidden = false;
        if(newlistname.characters.count == 0) {
            warninglabel.text = "List name cannot be blank";
        } else if(newlistname.characters.count >= 50){
            warninglabel.text = "List name must be shorter than 50 characters";
        } else if(availableWordLists != nil && availableWordLists.otherlists.contains(newlistname)) {
            warninglabel.text = "List name already exists";
        } else {
            warninglabel.text = "";
            
            if(renamelist != nil && oldname != nil && renamelist == true && oldname.characters.count > 0) {
                delegate?.renamethelist(oldname, newname: newlistname)
            } else {
                
                dismissViewControllerAnimated(true, completion: {
                    self.delegate?.createthenewlist(newlistname)
                })
                
                
                
            }
            
            
        }
        
    }
    
    let goldenRatio : CGFloat! = setGoldenRatio(UIScreen.mainScreen().bounds);
    
    override func viewDidLoad() {
        
        /** DEVICE-SIZE FORMATTING ADJUSTMENTS **/
        chooseaname.topAnchor.constraintEqualToAnchor(headerLabel.bottomAnchor, constant: 20 * goldenRatio).active = true;
        
        headerLabel.heightAnchor.constraintEqualToConstant(50 * goldenRatio).active = true;
        headerLabel.font = headerLabel.font.fontWithSize(20 * goldenRatio)
        txtCancelButton.titleLabel!.font = txtCancelButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtOKButton.titleLabel!.font = txtOKButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtOKButton.trailingAnchor.constraintEqualToAnchor(txtOKButton.superview?.trailingAnchor, constant: -(20 * goldenRatio)).active = true;
        txtCancelButton.trailingAnchor.constraintEqualToAnchor(txtCancelButton.superview?.trailingAnchor, constant:-(50.0 * goldenRatio + txtOKButton.frame.size.width)).active = true;
        chooseaname.font = chooseaname.font.fontWithSize(17*goldenRatio)
        textfield.font = textfield.font?.fontWithSize(17 * goldenRatio);
        textfield.topAnchor.constraintEqualToAnchor(chooseaname.bottomAnchor, constant: 8 * goldenRatio).active  = true;
        
        super.viewDidLoad()
        
        if(header != nil) {
            headerLabel.text = header;
        } else {
            headerLabel.text = "Assign a Name"
        }
        
        textfield.delegate = self
        //        currentavailablelists.append("Create a New List")
        
        
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLayoutSubviews() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRect(x: 0, y: textfield.frame.size.height - width, width:  textfield.frame.size.width, height: textfield.frame.size.height)
        
        border.borderWidth = width
        textfield.layer.addSublayer(border)
        textfield.layer.masksToBounds = true
    }
    
}



