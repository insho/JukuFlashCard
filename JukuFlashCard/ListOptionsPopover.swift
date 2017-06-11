//
//  ListOptionsPopover.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit

class ListOptionsPopover: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    var listoptions : [String]!;
    var delegate : CreateAListDelegate!;
    var listname : String!;
    var listsys : Int!;
    
    var selectedoption = "";
    
    @IBOutlet weak var txtCancelButton: UIButton!
    @IBOutlet weak var txtOKButton: UIButton!
    @IBAction func cancelbuttonPressed(sender: AnyObject) {
        //        delegate?.dismissthepopover()
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func okbuttonPressed(sender: AnyObject) {
        switch selectedoption {
        case "1. Clear List":
            
            let alert = UIAlertController(title: "Clear List", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
                //                self.delegate?.dismissthepopover()
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                self.delegate?.clearordeletethelist(self.listname,sys: self.listsys,delete: false)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        case "2. Rename List":
            dismissViewControllerAnimated(true, completion: {
                self.delegate?.showCreateListPopover(true, oldname: self.listname)
            })
            //            dismissViewControllerAnimated(true, completion: nil)
            
            
        case "3. Remove List":
            let alert = UIAlertController(title: "Remove List", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { action in
                //                self.delegate?.dismissthepopover()
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                self.delegate?.clearordeletethelist(self.listname,sys: self.listsys,delete: true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        default:
            dismissViewControllerAnimated(true, completion: nil)
            
            //            delegate?.dismissthepopover();
        }
        
        
    }
    @IBOutlet weak var maintableView: UITableView!
    
    @IBOutlet weak var titlelabel: UILabel!
    
    
    let goldenRatio : CGFloat! = setGoldenRatio(UIScreen.mainScreen().bounds);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maintableView.delegate = self;
        maintableView.dataSource = self;
        
        if(listname != nil) {
            titlelabel.text = listname;
            
        }
        
        /** DEVICE-SIZE Formatting **/
        titlelabel.heightAnchor.constraintEqualToConstant(50 * goldenRatio).active = true;
        titlelabel.font = titlelabel.font.fontWithSize(20 * goldenRatio)
        txtCancelButton.titleLabel!.font = txtCancelButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        txtOKButton.titleLabel!.font = txtOKButton.titleLabel!.font.fontWithSize(17*goldenRatio)
        
        txtOKButton.trailingAnchor.constraintEqualToAnchor(txtOKButton.superview?.trailingAnchor, constant: -(20 * goldenRatio)).active = true;
        
        
        txtCancelButton.trailingAnchor.constraintEqualToAnchor(txtCancelButton.superview?.trailingAnchor, constant:-(50.0 * goldenRatio + txtOKButton.frame.size.width)).active = true;
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedoption = listoptions[indexPath.row];
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 36 * goldenRatio;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listoptions.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("listoptionscell", forIndexPath: indexPath)
        cell.textLabel?.text = listoptions[indexPath.row];
        cell.textLabel?.font = cell.textLabel?.font.fontWithSize(18 * goldenRatio)
        
        if(listoptions.count == 1) {
            cell.userInteractionEnabled = false;
            selectedoption = listoptions[indexPath.row];
        } else {
            cell.userInteractionEnabled = true;
        }
        return cell;
    }
    
    
    
}