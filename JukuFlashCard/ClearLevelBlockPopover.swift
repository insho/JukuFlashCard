//
//  ClearLevelBlockPopover.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//


import UIKit

protocol ClearLevelBlockDelegate {
    func dismissthepopover() -> Void
    func clearthelevelblock(level: Int, block : Int!)
}


class ClearLevelBlockPopover: UIViewController {
    
    var delegate: ClearLevelBlockDelegate!
    var level: Int!;
    var block: Int!;
    
    
    @IBOutlet weak var txtCancelButton: UIButton!
    @IBOutlet weak var txtOKButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBAction func okButtonPressed(sender: AnyObject) {
        
        var alerttitle = "Clear Level"
        
        if(level != nil && level > 0 && block != nil && block > 0) {
            alerttitle = "Clear Block"
        }
        
        let alert = UIAlertController(title: alerttitle, message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
            self.delegate?.dismissthepopover()
        }))
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            self.delegate?.clearthelevelblock(self.level, block : self.block)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.dismissthepopover()
    }
    
    let goldenRatio : CGFloat! = setGoldenRatio(UIScreen.mainScreen().bounds);
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** DEVICE-SIZE Formatting **/
        titleLabel.heightAnchor.constraintEqualToConstant(50 * goldenRatio).active = true;
        titleLabel.font = titleLabel.font.fontWithSize(20 * goldenRatio)
        txtCancelButton.titleLabel!.font = txtCancelButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtOKButton.titleLabel!.font = txtOKButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        
        txtOKButton.trailingAnchor.constraintEqualToAnchor(txtOKButton.superview?.trailingAnchor, constant: -(20 * goldenRatio)).active = true;
        
        
        txtCancelButton.trailingAnchor.constraintEqualToAnchor(txtCancelButton.superview?.trailingAnchor, constant:-(50.0 * goldenRatio + txtOKButton.frame.size.width)).active = true;
        questionLabel.font = questionLabel.font.fontWithSize(17*goldenRatio)
        
        
        if(level != nil && level > 0 && block != nil && block > 0) {
            titleLabel.text = "Level \(level) Block \(block)"
            questionLabel.text = "Clear data for this block?"
        } else if (level != nil && level > 0 ) {
            titleLabel.text = "Level \(level)"
            questionLabel.text = "Clear data for this level?"
            
        }
        
    }
    
}

